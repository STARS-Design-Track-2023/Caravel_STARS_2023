/************************************************************************************************************/
// Inputs:
//    sequencer_on -> A 1 or 0 value which denotes that the chip is in sequencer mode if 1 and piano mode if 0
//    piano_note -> Any note value inputted which arrives from the keybord keys and keybord encoder
//    sequencer_note -> Any note value inputted which arrives from the sequencer
//
//    Outputs:
//    used_note -> Note to be sent to the lookup table depending on whether the chip is in piano or sequencer mode
//   
/*************************************************************************************************************/

module sequencer_piano_select (input logic sequencer_on, input logic [3:0]piano_note, sequencer_note, output logic [3:0]used_note);

always_comb begin
    if(sequencer_on)
    used_note = sequencer_note; // Selects note to send to lookup table based on if the sequencer is on or not 
    else
    used_note = piano_note;
end

endmodule