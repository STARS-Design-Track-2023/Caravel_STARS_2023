module main_game (
  input logic [31 : 0] notes1, notes2,
  input logic [2:0] mode,
  input logic clk, n_rst, button_1, button_2, 
  input logic [22:0] diff,
  output logic [13:0] out,
  output logic [7:0] num_misses, num_hits, score,
  output logic hit, missed, beat_clk, flash_on, is_neg
);
  logic [38 : 0] padded_notes1, padded_notes2;
  logic [22:0] counter; 
  logic [23:0] flash_counter, next_flash_counter;
  logic [15:0] num_hits_1, num_misses_1, num_hits_2, num_misses_2, total_num_hits, total_num_misses, total_score;
  logic [3:0] nine_cmp1, nine_cmp2;
  logic [15:0] disp_neg;
  logic scroll, pushed_1, pushed_2, hit_1, hit_2, missed_1, missed_2;

  // clk_div speed(.clk(clk), .n_rst(n_rst), .lim(diff), .hzX(scroll), .counter(counter));

  clk_div speed(.clk(clk), .n_rst(n_rst), .lim(diff), .hzX(scroll), .counter(counter), .mode(mode));
  sync_posedge edge_button_1(.mode(mode), .clk(clk), .n_rst(n_rst), .button(button_1), .posout(pushed_1));
  sync_posedge edge_button_2(.mode(mode), .clk(clk), .n_rst(n_rst), .button(button_2), .posout(pushed_2));
 
  scroll_and_display play_song(.mode(mode), .clk(clk), .n_rst(n_rst), .scroll(scroll), .notes1(notes1), .notes2(notes2), .padded_notes1(padded_notes1), .padded_notes2(padded_notes2), .out(out));

  hit_scanning_and_scoring scoring_button_1(.clk(clk), .n_rst(n_rst), .pushed(pushed_1), .mode(mode), .lim(diff), .padded_notes(padded_notes1), .counter(counter), .num_misses(num_misses_1), .num_hits(num_hits_1), .missed(missed_1), .good(hit_1));
  
  hit_scanning_and_scoring scoring_button_2(.clk(clk), .n_rst(n_rst), .pushed(pushed_2), .mode(mode), .lim(diff), .padded_notes(padded_notes2), .counter(counter), .num_misses(num_misses_2), .num_hits(num_hits_2), .missed(missed_2), .good(hit_2));

  assign beat_clk = scroll;

  bcdadd4 addhits(.a(num_hits_1), .b(num_hits_2), .ci(1'b0), .s(total_num_hits), .co());
  bcdadd4 addmisses(.a(num_misses_1), .b(num_misses_2), .ci(1'b0), .s(total_num_misses), .co());

  assign num_hits = (total_num_hits > 16'h99) ? 8'h99 : total_num_hits[7:0];
  assign num_misses = (total_num_misses > 16'h99) ? 8'h99 : total_num_misses[7:0];

  bcdaddsub4 calc_score(.a(total_num_hits), .b(total_num_misses), .op(1'b1), .s(total_score));
  bcd9comp1 comp(.in(total_score[3:0]), .out(nine_cmp1));
  bcd9comp1 comp1(.in(total_score[7:4]), .out(nine_cmp2));
  bcdadd4 make_neg(.a({8'b0, nine_cmp2, nine_cmp1}), .b(16'b0), .ci(1'b1), .s(disp_neg), .co());


  always_ff @ (posedge clk, negedge n_rst) begin
    if (~n_rst)
      flash_counter <= 0;
    else
      flash_counter <= next_flash_counter;
  end

  always_comb begin
    flash_on = 1'b1;
    is_neg = 0;
    next_flash_counter = flash_counter; //pause flash_counter

    if (total_score > 16'h99 && total_score < 16'h5000)  //cap at 99 when 99<total_score<5000
      score = 8'h99;
    else if (total_score >= 16'h5000) begin
      is_neg = 1'b1;

      if (flash_counter == 9999999) //2Hz clock only active when total_score is negative
        next_flash_counter = 0;
      else 
        next_flash_counter = flash_counter + 1;
      
      if (flash_counter < 4999999)//50/50 duty cycle to flash on and offwhen negative score
        flash_on = 1'b1;
      else
        flash_on = 1'b0;

      if (total_score <= 16'h9999 && total_score >= 16'h9901)
        score = disp_neg[7:0]; //disp negative value 
      else
        score = 8'h99; //cap at 99
    end
    else 
      score = total_score[7:0]; //defualt only holds when 0 <= score <= 99
  end


  assign missed  = missed_1 | missed_2;
  assign hit = hit_1 | hit_2;
 
endmodule
