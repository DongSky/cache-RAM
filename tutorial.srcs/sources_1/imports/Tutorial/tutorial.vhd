library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
library UNISIM;
use UNISIM.VComponents.all;
--some important ports and variables which should be used
Entity tutorial Is
port (
        BTNC : in std_logic;
        BTNR : in std_logic;
        jb : in std_logic_vector(3 downto 0);
        clk : in std_logic;
		swt : in std_logic_vector(15 downto 0);
		led : out std_logic_vector(15 downto 0);
		AN  : out std_logic_vector(7 downto 0);
		LED16_R :out std_logic;
		LED16_G :out std_logic;
		LED16_B :out std_logic;
		LED17_R :out std_logic;
        LED17_G :out std_logic;
        LED17_B :out std_logic;
		CA  : out std_logic;
		CB  : out std_logic;
		CC  : out std_logic;
		CD  : out std_logic;
		CE  : out std_logic;
		CF  : out std_logic;
		CG  : out std_logic;
		DP  : out std_logic
	);
end tutorial;
Architecture behavior of tutorial is
type arr_AN is array (7 downto 0) of integer; -- Array for output
signal num_AN:arr_AN; -- Array for AN
signal ANID:integer:=0; -- Pointer of AN which is prepared to be printed
signal cnt:integer:=0; --counter used to flush the 7-segment digit
type memory is array(63 downto 0) of std_logic_vector(63 downto 0);
type cachemem is array(7 downto 0) of std_logic_vector(63 downto 0);
type cacheblock is array(7 downto 0) of std_logic_vector(2 downto 0);
signal sram:memory;
signal addr:cacheblock;
signal cache:cachemem;
signal address : std_logic_vector(9 downto 0);--input address
signal wr:std_logic;--write or read flag
signal cs:std_logic;--chip enable flag
signal data : std_logic_vector(3 downto 0);--i/o interface
shared variable addr_tmp:integer:=0;
begin
    cs <= swt(15);--chip enable flag
    wr <= swt(14);--write or read flag
    led(15) <= cs;--chip enable flag led light
    led(14) <= wr;--write or read flag led light
    address <= swt(9 downto 0);--input address
    led(3 downto 0) <= data;
    process(clk)
    --display the number in 7-segment digit
        procedure get(signal addr1:in std_logic_vector(8 downto 3)) is
           begin
               addr(conv_integer(addr1(5 downto 3)))(2 downto 0) <= address(8 downto 6);
               cache(conv_integer(addr1(5 downto 3)))(63 downto 0) <= sram(conv_integer(address(8 downto 3)));
       end get;
        procedure print(constant x : in std_logic_vector(0 to 6)) is -- Print current logic vector to AN
        begin
            CA<=x(0);CB<=x(1);CC<=x(2);CD<=x(3);CE<=x(4);CF<=x(5);CG<=x(6);
        end print;
        procedure output(signal x:in integer) is -- Convert current charector to logic vector
        begin
            if(x=0)then print("0000001"); -- '0'
            elsif(x=1)then print("1001111"); -- '1'
            elsif(x=2)then print("0010010"); -- '2'
            elsif(x=3)then print("0000110"); -- '3'
            elsif(x=4)then print("1001100"); -- '4'
            elsif(x=5)then print("0100100"); -- '5'
            elsif(x=6)then print("0100000"); -- '6'
            elsif(x=7)then print("0001111"); -- '7'
            elsif(x=8)then print("0000000"); -- '8'
            elsif(x=9)then print("0000100"); -- '9'
            elsif(x=10)then print("0001000"); -- 'A'
            elsif(x=11)then print("1100000"); -- 'b'
            elsif(x=12)then print("0110001"); -- 'C'
            elsif(x=13)then print("1000010"); -- 'd'
            elsif(x=14)then print("0110000"); -- 'E'
            elsif(x=15)then print("0111000"); -- 'F'
            else print("1111111"); -- ' '
            end if;
        end output;
        procedure scan is -- Main output procedure of AN : Print num_AN on AN
        begin
            for i in 0 to 7 loop
                num_AN(i)<=conv_integer(addr(i)(2 downto 0));
            end loop;
            AN <= "11111111";
            AN(ANID) <= '0';
            ANID <= ANID + 1;
            if(ANID >= 7)then ANID <= 0; 
            end if;
            output(num_AN(ANID));
        end scan;
    --the end of display function
   begin
        if(clk'event and clk='1')then
        cnt<=cnt+1;
        if(cnt>100)then
            cnt<=0;
            scan;
        end if;
        if(cs='0')then
            addr_tmp:=0;
            if(address(0)='1')then addr_tmp:=addr_tmp+1; 
            end if;
            if(address(1)='1')then addr_tmp:=addr_tmp+2; 
            end if;
            if(address(2)='1')then addr_tmp:=addr_tmp+4; 
            end if;
            if(address(9)='1')then addr_tmp:=addr_tmp+8; 
            end if;
            if(wr='0')then
                led(13)<='0';
                data<=swt(13 downto 10);
                sram(conv_integer(address(8 downto 3)))(addr_tmp)<=data(0);
                sram(conv_integer(address(8 downto 3)))(addr_tmp+16)<=data(1);
                sram(conv_integer(address(8 downto 3)))(addr_tmp+32)<=data(2);
                sram(conv_integer(address(8 downto 3)))(addr_tmp+48)<=data(3);
                get(address(8 downto 3));            
            else
                if(not addr(conv_integer(address(5 downto 3)))(2 downto 0) = address(8 downto 6))then
                    get(address(8 downto 3));
                end if;
                data(0)<=cache(conv_integer(address(5 downto 3)))(addr_tmp);
                data(1)<=cache(conv_integer(address(5 downto 3)))(addr_tmp+16);
                data(2)<=cache(conv_integer(address(5 downto 3)))(addr_tmp+32);
                data(3)<=cache(conv_integer(address(5 downto 3)))(addr_tmp+48);
            end if;
        end if;
        end if;
    end process;
end behavior;