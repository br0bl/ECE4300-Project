#!/usr/bin/env python3
"""
Python reference + test vectors for the 16-element, 8-bit dot product:
    Y = sum_{i=0..15} A[i] * B[i]

1. Builds test vectors (edge cases + random).
2. Computes the golden result directly.
3. Models the 1-, 2-, and 4-MAC architectures (how each splits the work)
   and checks they all match the golden result.
4. Writes .mem files ($readmemh-ready) and a CSV for the Verilog testbench.

Usage:  python3 mac_reference.py [--unsigned] [--random N] [--seed S]
"""
import argparse
import random

N = 16
ACC_BITS = 20  # 16 * 255 * 255 = 1,040,400 < 2^20; signed worst case 16 * 128 * 128 = 262,144 fits too


def lo_hi(signed):
    return (-128, 127) if signed else (0, 255)


def golden(A, B):
    return sum(a * b for a, b in zip(A, B))


def run_mac_arch(A, B, num_macs):
    """Model an architecture with `num_macs` MAC units.
    Each MAC handles N/num_macs elements sequentially (one product per cycle),
    then partial sums are added together. Returns (result, compute_cycles)."""
    assert N % num_macs == 0
    per_mac = N // num_macs
    partials = []
    for m in range(num_macs):
        acc = 0
        for k in range(per_mac):
            i = m * per_mac + k  # contiguous split; any split gives same sum
            acc += A[i] * B[i]
        partials.append(acc)
    return sum(partials), per_mac  # ideal cycles, excludes pipeline/load/reduce overhead


def make_vectors(signed, n_random, seed):
    lo, hi = lo_hi(signed)
    rng = random.Random(seed)
    vecs = [
        ("all_zero", [0] * N, [0] * N),
        ("all_max", [hi] * N, [hi] * N),
        ("all_min", [lo] * N, [lo] * N),
        ("max_x_min", [hi] * N, [lo] * N),
        ("ones", [1] * N, [1] * N),
        ("ramp", list(range(N)), list(range(N, 0, -1))),
        ("alternating", [hi if i % 2 == 0 else lo for i in range(N)], [hi] * N),
    ]
    for t in range(n_random):
        vecs.append((f"rand_{t}", [rng.randint(lo, hi) for _ in range(N)],
                     [rng.randint(lo, hi) for _ in range(N)]))
    return vecs


def hex8(x):
    return f"{x & 0xFF:02X}"


def hexacc(x):
    return f"{x & ((1 << ACC_BITS) - 1):05X}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--unsigned", action="store_true")
    ap.add_argument("--random", type=int, default=20)
    ap.add_argument("--seed", type=int, default=4300)
    ap.add_argument("--outdir", default=".")
    args = ap.parse_args()
    signed = not args.unsigned

    vecs = make_vectors(signed, args.random, args.seed)
    fails = 0
    rows = []
    for name, A, B in vecs:
        g = golden(A, B)
        # range sanity: result must fit the accumulator
        lim = (1 << (ACC_BITS - 1)) if signed else (1 << ACC_BITS)
        lo_lim = -lim if signed else 0
        assert lo_lim <= g < lim, f"{name}: {g} overflows {ACC_BITS}-bit accumulator"
        for macs in (1, 2, 4):
            r, cyc = run_mac_arch(A, B, macs)
            if r != g:
                fails += 1
                print(f"FAIL {name} macs={macs}: got {r}, expected {g}")
        rows.append((name, A, B, g))

    # Write files for the Verilog testbench
    with open(f"{args.outdir}/vec_a.mem", "w") as fa, \
         open(f"{args.outdir}/vec_b.mem", "w") as fb, \
         open(f"{args.outdir}/expected.mem", "w") as fe, \
         open(f"{args.outdir}/vectors.csv", "w") as fc:
        fc.write("name,A,B,expected\n")
        for name, A, B, g in rows:
            fa.write(" ".join(hex8(a) for a in A) + "\n")
            fb.write(" ".join(hex8(b) for b in B) + "\n")
            fe.write(hexacc(g) + "\n")
            fc.write(f"{name},{' '.join(map(str, A))},{' '.join(map(str, B))},{g}\n")

    mode = "signed int8" if signed else "unsigned uint8"
    print(f"Mode: {mode}, accumulator: {ACC_BITS} bits")
    print(f"Vectors: {len(rows)} ({len(rows) - args.random} edge cases + {args.random} random)")
    print("Ideal compute cycles (no overhead): " +
          ", ".join(f"{m} MAC = {N // m}" for m in (1, 2, 4)))
    for name, A, B, g in rows[:7]:
        print(f"  {name:12s} -> {g}")
    print("RESULT:", "ALL PASS" if fails == 0 else f"{fails} FAILURES")
    print("Wrote vec_a.mem, vec_b.mem, expected.mem, vectors.csv")
    raise SystemExit(1 if fails else 0)


if __name__ == "__main__":
    main()
