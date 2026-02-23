#!/usr/bin/env python3
import argparse
import sys

# Correcting the import syntax to use an underscore
from my_lib import Calculator


def main():
    # 1. Initialize the parser
    parser = argparse.ArgumentParser(
        description="A simple command-line calculator.", epilog="Example: calc-cli -o add -a 3 -b 2"
    )

    # 2. Define the arguments
    parser.add_argument(
        "-o",
        "--operation",
        type=str,
        choices=["add", "divide"],
        required=True,
        help="The mathematical operation to perform.",
    )
    parser.add_argument("-a", "--a", type=float, required=True, help="The first number.")
    parser.add_argument("-b", "--b", type=float, required=True, help="The second number.")

    # 3. Parse the arguments from the shell
    args = parser.parse_args()

    # 4. Invoke the library logic
    calc = Calculator()

    try:
        if args.operation == "add":
            result = calc.add(args.a, args.b)
            print(f"Adding {args.a} + {args.b} = {result}")

        elif args.operation == "divide":
            result = calc.divide(args.a, args.b)
            print(f"Dividing {args.a} / {args.b} = {result}")

    except Exception as e:
        # Handle division by zero or other domain errors gracefully
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
