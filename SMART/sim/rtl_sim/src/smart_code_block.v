
initial
   begin
      $display("================= START SIMULATION ==============");

      repeat(80) @(posedge mclk);

      $display("================== END SIMULATION ===============");
      $finish();
   end

 always @(posedge dut.smart1.reset) begin
      $display("%h %h SAFE1 (%h < %h)", dut.smart1.ins_addr, dut.smart1.mem_addr*2+65536-`PMEM_SIZE, dut.smart1.LOW_SAFE*2+65536-`PMEM_SIZE, dut.smart1.HIGH_SAFE*2+65536-`PMEM_SIZE);
 end

  always @(posedge dut.smart2.reset) begin
      $display("%h %h SAFE2 (%h < %h)", dut.smart2.ins_addr, dut.smart2.mem_addr*2+65536-`PMEM_SIZE, dut.smart2.LOW_SAFE*2+65536-`PMEM_SIZE, dut.smart2.HIGH_SAFE*2+65536-`PMEM_SIZE);
 end

// always @ (posedge mclk) begin
// // always @ (e_state) begin
//     $display ("%h) %s - %s - %s", inst_pc, inst_full, i_state, e_state);
// end

// always @ (dut.smart2.ins_addr) begin
// // always @ (e_state) begin
//     $display ("> %h    %b", dut.smart2.ins_addr, mclk);
// end


// always @ (dut.smart2.mem_addr) begin
// // always @ (e_state) begin
//     $display ("* %h    %b", dut.smart2.mem_addr*2+65536-`PMEM_SIZE, mclk);
// end


// always @ (dut.cycle_count) begin
// // always @ (e_state) begin
//     $display ("%h", dut.cycle_count);
// end

// always @(posedge dut.reset_n) begin
// 	$display("RESET");
// end
