from caravel_cocotb.caravel_interfaces import * # import python APIs
import cocotb

caravelEnv : Caravel_env = None
half_clk_period : int = 0

ss7_table = [0b0111111,
             0b0000110,
             0b1011011,
             0b1001111,
             0b1100110,
             0b1101101,
             0b1111101,
             0b0000111,
             0b1111111,
             0b1100111]

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

def check_output(ex_dig_1, ex_dig_2, ex_blue, ex_red):
    # only read from pins used as outputs, other pins reads appear as unknown
    gpio_value = caravelEnv.monitor_gpio(29, 14).integer  # (25, 10) + 4
    # cocotb.log.info(f"[6] read {gpio_value}")

    expected_gpio_value = ((ss7_table[ex_dig_1] & 0x7F) << 7) | ((ss7_table[ex_dig_2] & 0x7F)) | ((ex_blue & 0x1) << 15) | ((ex_red & 0x1) << 14)
    if (gpio_value == expected_gpio_value):
        cocotb.log.info(f"[6] Correct output: {hex(gpio_value)}")
    else:
        cocotb.log.error(f"[6] Incorrect output, expected {hex(expected_gpio_value)}, read {hex(gpio_value)}")

@cocotb.test() # cocotb test marker
@report_test # wrapper for configure test reporting files
async def MatrixMonSTARS(dut):
    cocotb.log.info("[6] Start configuration")
    global caravelEnv
    caravelEnv = await test_configure(dut, timeout_cycles=2000000)
    cocotb.log.info("[6] Await mgmt_gpio")
    # ensure to drive input pins BEFORE running firmware with release_csb()
    caravelEnv.drive_gpio_in((13,0), 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info("[6] Finish configuration")
    global half_clk_period
    half_clk_period = caravelEnv.get_clock_period() / 2

    cocotb.log.info(f"[6] T1: Power-on-reset")
    # "reset" design
    caravelEnv.drive_gpio_in((13,0), 0x0)

    cocotb.log.info(f"[6] T2: Simple addition")
    # "reset" design
    caravelEnv.drive_gpio_in((13,0), 0x0)
    # wait 2 clk cycles
    await cocotb.triggers.ClockCycles(caravelEnv.clk,2)
    await cocotb.triggers.Timer(half_clk_period, 'ns')

    # select write mode
    await send_pb(2)
    # send first number
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(1)
    # wait before check
    await cocotb.triggers.ClockCycles(caravelEnv.clk,2)
    await cocotb.triggers.Timer(half_clk_period, 'ns')
    check_output(0, 1, 0, 0)

    # store value in a register
    await send_pb(6)
    # wait before check
    await cocotb.triggers.ClockCycles(caravelEnv.clk,2)
    await cocotb.triggers.Timer(half_clk_period, 'ns')
    check_output(0, 0, 0, 0)

    # send second number
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(1)
    await send_pb(0)
    # wait before check
    await cocotb.triggers.ClockCycles(caravelEnv.clk,2)
    await cocotb.triggers.Timer(half_clk_period, 'ns')
    check_output(0, 2, 0, 0)

    # store value in a register
    await send_pb(7)
    # wait before check
    await cocotb.triggers.ClockCycles(caravelEnv.clk,2)
    await cocotb.triggers.Timer(half_clk_period, 'ns')
    check_output(0, 0, 0, 0)

    # select read mode
    await send_pb(3)
    # select registers to read from
    await send_pb(6)
    await send_pb(7)
    # select opcode
    await send_pb(4)
    # wait before check
    await cocotb.triggers.ClockCycles(caravelEnv.clk,2)
    await cocotb.triggers.Timer(half_clk_period, 'ns')
    check_output(0, 3, 0, 0)

    cocotb.log.info(f"[6] T3: Double digit addition")
    # "reset" design
    caravelEnv.drive_gpio_in((13,0), 0x0)
    # wait 2 clk cycles
    await cocotb.triggers.ClockCycles(caravelEnv.clk,2)
    await cocotb.triggers.Timer(half_clk_period, 'ns')

    # select write mode
    await send_pb(2)
    # send first number
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(1)
    await send_pb(1)
    await send_pb(0)
    await send_pb(1)
    await send_pb(0)
    await send_pb(0)
    # wait before check
    await cocotb.triggers.ClockCycles(caravelEnv.clk,2)
    await cocotb.triggers.Timer(half_clk_period, 'ns')
    check_output(3, 4, 0, 0)

    # store value in a register
    await send_pb(6)
    # wait before check
    await cocotb.triggers.ClockCycles(caravelEnv.clk,2)
    await cocotb.triggers.Timer(half_clk_period, 'ns')
    check_output(0, 0, 0, 0)

    # send second number
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    await send_pb(1)
    await send_pb(0)
    await send_pb(1)
    await send_pb(0)
    await send_pb(0)
    await send_pb(0)
    # wait before check
    await cocotb.triggers.ClockCycles(caravelEnv.clk,2)
    await cocotb.triggers.Timer(half_clk_period, 'ns')
    check_output(2, 8, 0, 0)

