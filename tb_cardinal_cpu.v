`timescale 1ns/10ps

`define CYCLE_TIME 4

module tb_cardinal_cpu;

reg clk, reset;
wire [31:0] inst_in;	// Instruction data
wire [31:0] pc_out;		// PC from where instruction should be fetched
wire [63:0] d_in ;		// Data input for the load word 
wire [31:0] addr_out;	// Which address memory should be written or read
wire memEn ;			// For Load word
wire memWrEn;			// For Store Word
wire [63:0] d_out ;		// Data out for the store word to be written in Memory

parameter clock_period = 4;

integer cycle_number;
integer i;
integer dmem_dump_file_1, dmem_dump_file_2, dmem_dump_file_3;

cardinal_cpu dut (clk, reset, inst_in, d_in, pc_out, addr_out, memEn, memWrEn, d_out);

imem Ins_Cache (
	.memAddr		(pc_out[29:22]),	// Only 8-bits are used in this project
	.dataOut		(inst_in)		// 32-bit  Instruction
	);

dmem DM_Cache (
	.clk 		(clk),				// System Clock
	.memEn		(memEn),			// data-memory enable (to avoid spurious reads)
	.memWrEn	(memWrEn),		// data-memory Write Enable
	.memAddr	(addr_out[31:24]),	// 8-bit Memory address
	.dataIn		(d_out),			// 64-bit data to data-memory
	.dataOut	(d_in)			// 64-bit data from data-memory
	);	

always #2 clk = ~clk;

initial	
	begin
		//Testing the imem_1 instructions which are already provided
		$readmemh("./testcase/imem_1.fill", Ins_Cache.MEM); 	// loading instruction memory into node0
		$readmemh("./testcase/dmem.fill", DM_Cache.MEM); 	// loading data memory into dmem		
		clk = 0;
		reset = 1;
		#(4*clock_period); reset = 0;
		wait (inst_in == 32'h00000000);
		$display("The program completed in %d cycles", cycle_number);
		// Let us now flush the pipe line
		repeat(5) @(negedge clk);
		// Open file for output
		dmem_dump_file_1 = $fopen("./report/dmem_output_1.dump");
		// Let us now dump all the locations of the data memory now
		for (i=0; i<128; i=i+1) 
		begin
			$fdisplay(dmem_dump_file_1, "Memory location #%d : %h ", i, DM_Cache.MEM[i]);			
		end
		$fclose (dmem_dump_file_1);
		#(5*clock_period);

		//Testing custom file which has all the instructions
		$readmemh("./testcase/imem_2.fill", Ins_Cache.MEM); 	// loading instruction memory into node0
		$readmemh("./testcase/dmem.fill", DM_Cache.MEM); 	// loading data memory into dmem		
		reset = 1;
		#(4*clock_period); reset = 0;
		wait (inst_in == 32'h00000000);
		$display("The program completed in %d cycles", cycle_number);
		// Let us now flush the pipe line
		repeat(5) @(negedge clk);
		// Open file for output
		dmem_dump_file_2 = $fopen("./report/dmem_output_2.dump");
		// Let us now dump all the locations of the data memory now
		for (i=0; i<128; i=i+1) 
		begin
			$fdisplay(dmem_dump_file_2, "Memory location #%d : %h ", i, DM_Cache.MEM[i]);			
		end
		$fclose (dmem_dump_file_2);
		#(5*clock_period);	

		//Testing Branch related instructions
		$readmemh("./testcase/imem_3.fill", Ins_Cache.MEM); 	// loading instruction memory into node0
		$readmemh("./testcase/dmem.fill", DM_Cache.MEM); 	// loading data memory into dmem		
		reset = 1;
		#(4*clock_period); reset = 0;
		wait (inst_in == 32'h00000000);
		$display("The program completed in %d cycles", cycle_number);
		// Let us now flush the pipe line
		repeat(5) @(negedge clk);
		// Open file for output
		dmem_dump_file_3 = $fopen("./report/dmem_output_3.dump");
		// Let us now dump all the locations of the data memory now
		for (i=0; i<128; i=i+1) 
		begin
			$fdisplay(dmem_dump_file_3, "Memory location #%d : %h ", i, DM_Cache.MEM[i]);			
		end
		$fclose (dmem_dump_file_3);
		#(5*clock_period);
		$stop;
	end



//// ******************** Cycle Counter ******************** \\\\

always @ (posedge clk)
begin
	if (reset)
		cycle_number <= 0;
	else
		cycle_number <= cycle_number + 1;
end

endmodule
 `undef CYCLE_TIME
