import logging

from my_lib.calculator import Calculator

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")


if __name__ == "__main__":
    calculator = Calculator()
    result_sum = calculator.add(2, 3)
    result_div = calculator.divide(5, 2)
    logging.info(f"➕ Result of addition (2 + 3) = {result_sum}")
    logging.info(f"➗ Result of division (5 / 2) = {result_div}")
