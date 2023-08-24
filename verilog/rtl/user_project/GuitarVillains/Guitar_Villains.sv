module Guitar_Villains(
    input logic clk,
    input logic n_rst,
    input logic [3:0]button,
    input logic chip_select,



    output logic [6:0]top_row,
    output logic [6:0]bottom_row,
    output logic red_disp,
    output logic green_disp,
    output logic [6:0]ss0,
    output logic [6:0]ss1

);
  logic button2_act, button3_act;     
  logic [22:0]diff_speed;
  logic finishpulse;
  logic beat_clk;
  logic [31:0]notes[1:0];  // song_display disp_song( .clk(hwclk), .nrst(~pb[19]), .toggle_green(green), .toggle_red(red), .toggle(pb[3]), .note(pb[1:0]), .mode(mode), .note1(notes[0]), .note2(notes[1]), .display_note1(left[6:0]), .display_note2(right[6:0]), .units(ss0[6:0]), .tens(ss1[6:0]));

  logic [13:0]finish_vals;

  //Displays what mode, btwn IDLE, EDIT, DIFFICULTY, RUN, PAUSE, FINISH using LEDs
  logic [2:0]mode; 
  //Displays what level, btwn EASY, MEDIUM, HARD using LEDs
  logic [1:0]level;
  //Displays final score and highest score on SSD 
  logic [7:0]score;
  logic [7:0]num_misses;
  logic [7:0]num_hits;

  //logic toggle_state;
  logic toggle_state;
  logic [4:0]position;

  //disp for curr score
  logic [13:0] curr_score;

  //Notes being played. Displayed via both rows of LEDs
  logic [13:0]outputs;

  //If the user hits the note on time or if they miss the note. Displayed via multicolored LED
  logic hit;
  logic missed;

  //enable to flash when negative
  logic flash_on;

  //tracks sign of score
  logic is_neg;

  //For EDIT DISPLAY Module
  logic toggle1;
  logic toggle2;

  //Displays the edited notes
  logic [6:0]ed_disp1;
  logic [6:0]ed_disp2;

  //Displays the current position of the edit
  logic [6:0]units;
  logic [6:0]tens;

  logic o_red;
  logic o_green;

  localparam IDLE = 3'd1;
  localparam EDIT = 3'd2;
  localparam DIFF = 3'd3;
  localparam RUN = 3'd4;
  localparam PAUSE = 3'd5;
  localparam FINISH = 3'd6;

  always_comb begin
    if(~chip_select) begin
      button2_act = button[2];
      button3_act= button[3]; 
  end
  else begin
    button2_act = 0;
    button3_act= 0; 
  end
  end

// assign finishpulse = 1'b0;

  //All of the DISPLAYED Outputs
  always_comb begin
    if(~chip_select) begin
    case(mode)
      IDLE: begin
        green_disp = 1'b0;
        red_disp = 1'b0;
        top_row = 7'b1111111;
        bottom_row = 7'b1111111;
        ss1 = 7'b0;
        ss0 = 7'b0;
      end
      EDIT: begin
        green_disp = toggle1;
        red_disp = toggle2;
        top_row = ed_disp2;
        bottom_row = ed_disp1;
        ss0 = units;
        ss1 = tens;
      end
      DIFF: begin
        top_row = 7'b0;
        red_disp = 1'b0;
        green_disp = 1'b0;
        bottom_row = 7'b0;

        case(level)
          2'd1:
          begin
            ss0 = 7'b0000110;
            ss1 = 7'b1011110;
          end
          2'd2:
          begin
            ss0 = 7'b1011011;
            ss1 = 7'b1011110;
          end
          2'd3:
          begin
            ss0 = 7'b1001111;
            ss1 = 7'b1011110;
          end
          default:
          begin
            ss0 = 7'b0;
            ss1 = 7'b0;
          end

        endcase
      end

      RUN: begin
        green_disp = hit;
        red_disp = missed;
        top_row = outputs[6:0];
        bottom_row = outputs[13:7];
        {ss1, ss0} = curr_score;
      end

      PAUSE: begin
        green_disp = hit;
        red_disp = missed;
        top_row = outputs[6:0];
        bottom_row = outputs[13:7];
        {ss1, ss0} = curr_score;
      end

      FINISH: begin
        green_disp = o_green;
        red_disp = o_red;
        {ss1, ss0} = finish_vals;
        top_row = 7'b0;
        bottom_row = 7'b0;
      end

      default: begin
        green_disp = 1'b0;
        red_disp = 1'b0;
        top_row = 7'b0;
        bottom_row = 7'b0;
        ss1 = 7'b0;
        ss0 = 7'b0;
      end
    endcase
    end 
    else begin
       green_disp = 1'b0;
        red_disp = 1'b0;
        top_row = 7'b0;
        bottom_row = 7'b0;
        ss1 = 7'b0;
        ss0 = 7'b0;
    end
  end

  //DO NOT USE BUTTON 3 - Quit Button - Used in State FSM
  //BUTTON 2: Used to Switch between Modes : Always Running
  
  //Checks when all notes have been played
  //Sends out pulse for when notes are all finished
  finish_counter pulseout(.clk(clk), .n_rst(n_rst), .beat_clk(beat_clk), .finish(finishpulse));

  //State FSM (Switches between the states)
  //Uses pushbutton 3 and pushbuton 4
  state_fsm modetrans(.clk(clk), .n_rst(n_rst), .pushed_3(button2_act), .pushed_4(button3_act), .fin_check(finishpulse), .mode(mode));

  //Difficulty FSM (Lets user pick their levels)
  //Uses pushbutton 1
  diff_speed lvls(.clk(clk), .n_rst(n_rst), .mode(mode), .pushed_1(button[1]), .diff_speed(diff_speed), .level(level));

  //Scoring, keyshifting, and noteshifting all in one

  main_game game(.clk(clk), .n_rst(n_rst), .mode(mode), .notes1(notes[0]), .notes2(notes[1]), .diff(diff_speed), .button_1(button[0]), .button_2(button[1]), .out(outputs), .num_misses(num_misses), .num_hits(num_hits), .hit(hit), .missed(missed), .score(score), .beat_clk(beat_clk), .flash_on(flash_on), .is_neg(is_neg));

  
  //converts bcd score to ss display
  bcdssdec curr_score_disp(.enable(flash_on), .in(score), .out(curr_score));

  //Sets the Highest Score after Each Round
  NEW_high_score_check highest_score(.clk(clk), .n_rst(n_rst), .flash(flash_on), .is_neg(is_neg), .score(score), .mode(mode), .score_tog(button[0]), .hits(num_hits), .misses(num_misses), .SS_disp(finish_vals), .red(o_red), .green(o_green));

  
  //Displays the Song while editing
  //Uses Pushbutton 2 to toggle between the song
  //Uses Pushbutton 1 and 0 to select the note
  song_display disp_song( .clk(clk), .nrst(n_rst), .toggle_green(toggle1), .toggle_red(toggle2), .toggle(button[3]), .note(button[1:0]), .mode(mode), .note1(notes[0]), .note2(notes[1]), .display_note1(ed_disp1), .display_note2(ed_disp2), .units(units), .tens(tens));
  
  
  
endmodule
