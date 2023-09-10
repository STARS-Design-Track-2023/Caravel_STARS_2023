from caravel_cocotb.caravel_interfaces import * # import python APIs
import cocotb

caravelEnv : Caravel_env = None
half_clk_period : int = 0

outputGPIO = 19 #Output signal to send to speaker (15+4)
 
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

async def synchronizeWithPWM():
    #A non-zero note MUST be playing

    noNoteCheck = 0 #If this exceeds 20000, no note is playing (under standard testing conditions)

    #Initialize the currentOutput
    currentOutput = caravelEnv.monitor_gpio(outputGPIO).integer

    #Wait for a low signal
    while (currentOutput != 0 and noNoteCheck < 20000):
        noNoteCheck = noNoteCheck + 1
        await cocotb.triggers.Timer(half_clk_period * 2, 'ns')
        currentOutput = caravelEnv.monitor_gpio(outputGPIO).integer

    #Wait for a high signal
    while (currentOutput != 1 and noNoteCheck < 20000):
        noNoteCheck = noNoteCheck + 1
        await cocotb.triggers.Timer(half_clk_period * 2, 'ns')
        currentOutput = caravelEnv.monitor_gpio(outputGPIO).integer

    assert noNoteCheck < 20000, "Tried to synchronize PWM with no note playing"

    #This ends ready to run getNextPWM(on the rising edge)
    return

async def getNextPWM():
    #Assumes that it starts on the rising edge for PWM values 1-255 (or no edge for 0)
    
    #Initialize the currentOutput
    currentOutput = caravelEnv.monitor_gpio(outputGPIO).integer

    clockCycleCount = 0 #Set to zero on the first clock cycle where the output is low

    #Count cycles while PWM is high
    while (currentOutput == 1):
        clockCycleCount = clockCycleCount + 1
        await cocotb.triggers.Timer(half_clk_period * 2, 'ns')
        currentOutput = caravelEnv.monitor_gpio(outputGPIO).integer

    pwmSignal = clockCycleCount

    #Make sure to run 256 clock cycles
    while (clockCycleCount < 256):
        clockCycleCount = clockCycleCount + 1
        await cocotb.triggers.Timer(half_clk_period * 2, 'ns')

    #clockCycleCount now contains the number of high clock cycles per cycle
    return pwmSignal

async def getNoteCycleCount():
    #Assumes that note has been playing long enough that current PWM is part of the current note's sequence
    #Also note that since the actual frequency is not a multiple of 256, this is only approximate

    #I think that the way that it(DUT) should work is that the PWM's target value is constantly udated and if the 
    #PWM counter is less than this target value, it outputs a high.  This means that for small wavelengths, not
    #every PWM value is hit and the PWM values that are hit may change from cycle to cycle.  At least 18 pwm values
    #are produced though, so there is at least 1 increase and 1 decrease per cycle
    #I set it to:
    #1) wait for a increase (zero phase with reference to wave)
    #2) wait for a decrease (zero phase with reference to wave)
    #3) start counting full cycles for 10 cycles (should get close enough based on preliminary calcs: ~34 clock cycle error for fastest note)
    #   a)wait for an increase
    #   b)wait for a decrease
    #   c)increment counter
    await synchronizeWithPWM()#align with rising edge of any pwm pulse
    pwm = await getNextPWM()#advance one pwm cycle and read the pwm value
    nextPwm = await getNextPWM()

    #While decreasing or constant
    while(nextPwm <= pwm):
        pwm = nextPwm
        nextPwm = await getNextPWM()

    #While increasing or constant
    while(nextPwm >= pwm):
        pwm = nextPwm
        nextPwm = await getNextPWM()

    cycleCounter = 0
    while(cycleCounter < 10):
        #While decreasing or constant
        while(nextPwm <= pwm):
            pwm = nextPwm
            nextPwm = await getNextPWM()

        #While increasing or constant
        while(nextPwm >= pwm):
            pwm = nextPwm
            nextPwm = await getNextPWM()
        
        #One full cycle completed
        cycleCounter = cycleCounter + 1

    #10 cycles tracked, 256 clock cycles per PWM
    return cycleCounter*256/10

async def getNoteShape():
    #This uses similar code as 'getNoteCycleCount'.  See that function for comments about my thought process
    #Here, 10 waves are tracked while the rising and falling edges are counted.  Square waves only have one of each
    #Triangle have many of each, and sawtooth only have one falling edge

    await synchronizeWithPWM()#align with rising edge of any pwm pulse
    pwm = await getNextPWM()#advance one pwm cycle and read the pwm value
    nextPwm = await getNextPWM()

    #While decreasing or constant
    while(nextPwm <= pwm):
        pwm = nextPwm
        nextPwm = await getNextPWM()

    #While increasing or constant
    while(nextPwm >= pwm):
        pwm = nextPwm
        nextPwm = await getNextPWM()

    cycleCounter = 0
    risingEdgeCounter = 0#The initial rising edge will be snagged again at the end
    fallingEdgeCounter = 0

    while(cycleCounter < 10):
        #While decreasing or constant
        while(nextPwm <= pwm):
            if(nextPwm < pwm):
                #Falling edge detected
                fallingEdgeCounter = fallingEdgeCounter + 1
            pwm = nextPwm
            nextPwm = await getNextPWM()

        #While increasing or constant
        while(nextPwm >= pwm):
            if(nextPwm > pwm):
                #Rising edge detected
                risingEdgeCounter = risingEdgeCounter + 1
            pwm = nextPwm
            nextPwm = await getNextPWM()
        
        #One full cycle completed
        cycleCounter = cycleCounter + 1

    waveType = 0 #default, no sound
    if(risingEdgeCounter == 10 and fallingEdgeCounter == 10):
        waveType = 3#Square
    elif(risingEdgeCounter > 10 and fallingEdgeCounter > 10):
        waveType = 1#Triangle
    elif(risingEdgeCounter > 10 and fallingEdgeCounter == 10):
        waveType = 2#Saw

    #10 cycles tracked, 256 clock cycles per PWM
    return waveType

async def testIfNotePlaying():

    currentOutput = caravelEnv.monitor_gpio(outputGPIO).integer
    
    await cocotb.triggers.Timer(half_clk_period * 2, 'ns')

@cocotb.test() # cocotb test marker
@report_test # wrapper for configure test reporting files
async def TMNT(dut):
    cocotb.log.info("[12] Start configuration")
    global caravelEnv
    caravelEnv = await test_configure(dut)
    cocotb.log.info("[12] Await mgmt_gpio")
    caravelEnv.drive_gpio_in((18,0), 0x0)
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info("[12] Finish configuration")
    global half_clk_period
    half_clk_period = caravelEnv.get_clock_period() / 2

    cocotb.log.info(f"[12] T1: Power-on-reset")
    # reset design
    caravelEnv.drive_gpio_in((18,0), 0x0)
    # wait 2 clk cycles
    await cocotb.triggers.ClockCycles(caravelEnv.clk,2)

    #Push buttons not on clk rising edge
    await cocotb.triggers.Timer(half_clk_period, 'ns')
    await send_pb(14)#mode key

    #Hold the 6 key
    caravelEnv.drive_gpio_in(10, 0x1)
    cocotb.log.info(f"[12] Note: 6-2, wavelength[{int(await getNoteCycleCount())}/{int(27045)}], shape[{await getNoteShape()}/{int(1)}]")

    assert testIfNotePlaying()
    await getNoteCycleCount()
    await getNoteShape()
