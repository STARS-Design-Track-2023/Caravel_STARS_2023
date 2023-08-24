/************************************************************************************************************/
// Inputs:
//    beat -> current beat the sycnroniser is on (0-7)
//    sequencer_on -> A 1 or 0 value which denotes that the chip is in sequencer mode if 1 and piano mode if 0
//
// Outputs:
//    to_led -> Signal depicting which light should be on in the fpga
/*************************************************************************************************************/

module beat_to_led_dec (input logic [3:0]beat, input logic sequencer_on, output logic [7:0]to_led);

    always_comb begin

        if(sequencer_on) begin
            case(beat)
            4'd0: to_led = 8'b00000001;
            4'd2: to_led = 8'b00000010;
            4'd4: to_led = 8'b00000100;
            4'd6: to_led = 8'b00001000;
            4'd8: to_led = 8'b00010000;
            4'd10: to_led = 8'b00100000;
            4'd12: to_led = 8'b01000000;
            4'd14: to_led = 8'b10000000;
            default: to_led = 8'b0;
            endcase
        end
        else
            to_led = 8'b0;

    end

endmodule