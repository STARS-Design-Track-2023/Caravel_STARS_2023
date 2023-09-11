from caravel_cocotb.caravel_interfaces import * # import python APIs
import cocotb

caravelEnv : Caravel_env = None
half_clk_period : int = 0

async def send_pb(val):
    if val > 0: val += 4
    # negedge
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')
    caravelEnv.drive_gpio_in(val, 0x1)
    # negedge
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')
    caravelEnv.drive_gpio_in(val, 0x0)
    # negedge
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')

@cocotb.test() # cocotb test marker
@report_test # wrapper for configure test reporting files
async def GuitarVillains(dut):
    cocotb.log.info("[5] Start configuration")
    global caravelEnv
    caravelEnv = await test_configure(dut, timeout_cycles=2000000)
    cocotb.log.info("[5] Await mgmt_gpio")
    caravelEnv.drive_gpio_in((7,0), 0x0)
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info("[5] Finish configuration")
    global half_clk_period
    half_clk_period = caravelEnv.get_clock_period() / 2

    cocotb.log.info(f"[5] T1: Power-on-reset")
    # reset design
    caravelEnv.drive_gpio_in((7,0), 0x0)

    await cocotb.triggers.ClockCycles(caravelEnv.clk, 2)
    await send_pb(2)  # edit mode

    await cocotb.triggers.ClockCycles(caravelEnv.clk, 2)
    await send_pb(1)  # note
    await cocotb.triggers.ClockCycles(caravelEnv.clk, 2)
    await send_pb(1)  # note
    await cocotb.triggers.ClockCycles(caravelEnv.clk, 2)
    await send_pb(0)  # rest
    await cocotb.triggers.ClockCycles(caravelEnv.clk, 2)
    await send_pb(1)  # note

    await cocotb.triggers.ClockCycles(caravelEnv.clk, 2)
    await send_pb(2)  # difficulty control mode

    await cocotb.triggers.ClockCycles(caravelEnv.clk, 2)
    await send_pb(2)  # play mode
    await cocotb.triggers.ClockCycles(caravelEnv.clk, 100)

    await cocotb.triggers.ClockCycles(caravelEnv.clk, 2)
    await send_pb(2)  # finish mode
    await cocotb.triggers.ClockCycles(caravelEnv.clk, 10)
