from vunit import VUnit
import numpy as np
from pathlib import Path

NOF_VECTOR_TEST = 20
DATA_WIDTH = 8
CURRENT_DIR = Path(__file__).resolve().parent

def make_pre_config(testname):
    def pre_config(output_path):
        arr_random_int_a = np.random.randint(-2**(DATA_WIDTH-1)-1, 2**(DATA_WIDTH-1)-1, NOF_VECTOR_TEST)
        arr_random_int_b = np.random.randint(-2**(DATA_WIDTH-1)-1, 2**(DATA_WIDTH-1)-1, NOF_VECTOR_TEST)

        a_file_path = CURRENT_DIR  / f"{testname}_input_0.csv"
        b_file_path = CURRENT_DIR  / f"{testname}_input_1.csv"

        np.savetxt(a_file_path, arr_random_int_a, delimiter=",", fmt='%i')
        np.savetxt(b_file_path, arr_random_int_b, delimiter=",", fmt='%i')

        return True
    return pre_config

def make_post_check(testname):
    def post_check(output_path):
        arr_int_a = np.loadtxt(CURRENT_DIR / f"{testname}_input_0.csv", delimiter=",", dtype=int)
        arr_int_b = np.loadtxt(CURRENT_DIR / f"{testname}_input_1.csv", delimiter=",", dtype=int)
        arr_int_sum = np.loadtxt(CURRENT_DIR / f"{testname}_output.csv", delimiter=",", dtype=int)
        expected_sum = arr_int_a + arr_int_b

        is_equal = np.array_equal(arr_int_sum, expected_sum)
        print(is_equal)

        return np.array_equal(arr_int_sum, expected_sum)
    return post_check


vu = VUnit.from_argv(compile_builtins=True)
vu.add_vhdl_builtins()
vu.add_array_util()

common_lib = vu.add_library("common")
common_lib.add_source_files("../src/type_declaration_pkg.vhd")

dsp_lib = vu.add_library("dsp")
dsp_lib.add_source_files("../src/sub.vhd")
dsp_lib.add_source_files("../src/adder.vhd")

src_lib = vu.add_library("src_lib")
src_lib.add_source_files("../src/top.vhd")

tb_lib = vu.add_library("tb_lib")
tb_lib.add_source_files("top_tb.vhd")

if vu.get_simulator_name() == "ghdl":
    vu.set_compile_option("ghdl.a_flags", ["--std=08"])
    vu.set_sim_option("ghdl.sim_flags", ["--wave=./wave.ghw"])

test_name = "check_adder"
test_checker = tb_lib.test_bench("top_tb").test(test_name)
test_checker.set_generic("g_TB_PATH", CURRENT_DIR)
test_checker.set_generic("g_TEST_NAME", test_name)
test_checker.set_pre_config(make_pre_config(test_name))
test_checker.set_post_check(make_post_check(test_name))

vu.main()