from caravel_cocotb.caravel_interfaces import * # import python APIs
import cocotb

caravelEnv : Caravel_env = None
half_clk_period : int = 0

@cocotb.test() # cocotb test marker
@report_test # wrapper for configure test reporting files
async def EightyTwos(dut):
    cocotb.log.info("[3] Start configuration")
    global caravelEnv
    caravelEnv = await test_configure(dut, timeout_cycles=2000000)
    cocotb.log.info("[3] Await mgmt_gpio")
    caravelEnv.drive_gpio_in(0, 0x82 & 0x1)
    caravelEnv.drive_gpio_in((11,5), 0x82 >> 1)
    caravelEnv.drive_gpio_in(27, 0x0)
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info("[3] Finish configuration")
    global half_clk_period
    half_clk_period = caravelEnv.get_clock_period() / 2

    cocotb.log.info(f"[3] T1: Add register to accumulator")
    await cocotb.triggers.Timer(half_clk_period, 'ns')  # negedge
    cocotb.log.info(f"[3] T1: MVI D")
    caravelEnv.drive_gpio_in(0, 0x16 & 0x1)
    caravelEnv.drive_gpio_in((11,5), 0x16 >> 1)
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')  # posedge, negedge
    caravelEnv.drive_gpio_in(0, 21 & 0x1)
    caravelEnv.drive_gpio_in((11,5), 21 >> 1)
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')  # posedge, negedge
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')  # posedge, negedge

    cocotb.log.info(f"[3] T1: MVI A")
    caravelEnv.drive_gpio_in(0, 0x3E & 0x1)
    caravelEnv.drive_gpio_in((11,5), 0x3E >> 1)
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')  # posedge, negedge
    caravelEnv.drive_gpio_in(0, 80 & 0x1)
    caravelEnv.drive_gpio_in((11,5), 80 >> 1)
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')  # posedge, negedge
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')  # posedge, negedge

    cocotb.log.info(f"[3] T1: ADD D")
    caravelEnv.drive_gpio_in(0, 0x82 & 0x1)
    caravelEnv.drive_gpio_in((11,5), 0x82 >> 1)
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')  # posedge, negedge
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')  # posedge, negedge

    cocotb.log.info(f"[3] T1: STAX B")
    caravelEnv.drive_gpio_in(0, 0x02 & 0x1)
    caravelEnv.drive_gpio_in((11,5), 0x02 >> 1)
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')  # posedge, negedge
    caravelEnv.drive_gpio_in(27, 0x1)
    caravelEnv.release_gpio(0)
    caravelEnv.release_gpio((11,5))
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')  # posedge, negedge

    output = caravelEnv.monitor_gpio(0).integer | (caravelEnv.monitor_gpio((11,5)).integer << 1)
    assert output == 101, "[3] T1: Incorrect output!"

    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')  # posedge, negedge
