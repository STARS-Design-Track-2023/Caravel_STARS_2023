from caravel_cocotb.caravel_interfaces import test_configure
from caravel_cocotb.caravel_interfaces import report_test
import cocotb 

@cocotb.test()
@report_test
async def DigiDoggs(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=1346140)

    cocotb.log.info(f"[TEST] Start DigiDoggs test")  
    # wait for start of sending
    caravelEnv.drive_gpio_in((7, 0), 0x0)
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info(f"[TEST] finish configuration")

    caravelEnv.drive_gpio_in((7, 0), 0x0)
    await cocotb.triggers.ClockCycles(caravelEnv.clk, 1)

    # caravelEnv.drive_gpio_in((34, 37), 0x1) # CHECK TO MAKE SURE ITS CORRECT
    caravelEnv.drive_gpio_in(5, 0x1)  # GPIO[1(+4)]
    await cocotb.triggers.ClockCycles(caravelEnv.clk, 10)

    caravelEnv.drive_gpio_in(6, 0x1)

    await cocotb.triggers.Timer(425/2, 'ns')
    caravelEnv.drive_gpio_in(0, 0x1)  # GPIO[0]
    await cocotb.triggers.Timer(425/2, 'ns')
    caravelEnv.drive_gpio_in(0, 0x0)  # GPIO[0]

    caravelEnv.drive_gpio_in(6, 0x0)

    for i in range(0, 63):
        await cocotb.triggers.Timer(425/2, 'ns')
        caravelEnv.drive_gpio_in(0, 0x1)  # GPIO[0]
        await cocotb.triggers.Timer(425/2, 'ns')
        caravelEnv.drive_gpio_in(0, 0x0)  # GPIO[0]

    await cocotb.triggers.ClockCycles(caravelEnv.clk, 2)
    caravelEnv.drive_gpio_in(5, 0x0)  # GPIO[1(+4)]
    await cocotb.triggers.ClockCycles(caravelEnv.clk, 400)
    

    # overwrite_val = 7 # value will be written to the counter by la 
    # # expect value bigger than 7 
    # await caravelEnv.wait_mgmt_gpio(0) # wait until writing 7 through la 
    # received_val = int ((caravelEnv.monitor_gpio(37,30).binstr + caravelEnv.monitor_gpio(7,0).binstr ),2) 
    # counter = overwrite_val

    # if received_val != counter :
    #     cocotb.log.fatal(f"LA writing is in correct: {overwrite_val} receieved: {received_val}")
    # await cocotb.triggers.ClockCycles(caravelEnv.clk,1)

    # # wait until the LA writing is disabled 
    # while (received_val == counter): 
    #     await cocotb.triggers.ClockCycles(caravelEnv.clk,1)
    #     received_val = int ((caravelEnv.monitor_gpio(37,30).binstr + caravelEnv.monitor_gpio(7,0).binstr ),2) 

    # counter = received_val
    # for i in range(100):
    #     if counter != int ((caravelEnv.monitor_gpio(37,30).binstr + caravelEnv.monitor_gpio(7,0).binstr ),2) :
    #         cocotb.log.error(f"counter have wrong value expected = {counter} recieved = {int ((caravelEnv.monitor_gpio(37,30).binstr + caravelEnv.monitor_gpio(7,0).binstr ),2) }")
    #     await cocotb.triggers.ClockCycles(caravelEnv.clk,1)
    #     counter +=1
    