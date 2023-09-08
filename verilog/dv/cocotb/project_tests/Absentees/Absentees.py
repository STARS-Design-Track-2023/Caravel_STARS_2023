from caravel_cocotb.caravel_interfaces import * # import python APIs
import cocotb

caravelEnv : Caravel_env = None
half_clk_period : int = 0

@cocotb.test() # cocotb test marker
@report_test # wrapper for configure test reporting files
async def Absentees(dut):
    cocotb.log.info("[1] Start configuration")
    caravelEnv = await test_configure(dut, timeout_cycles=2000000)
    cocotb.log.info("[1] Await mgmt_gpio")
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info("[1] Finish configuration")
    half_clk_periodclk_period = caravelEnv.get_clock_period() / 2

    
