-- La siguiente descripción de hardware sirve para enviar una palabra de 12 bits via SPI
-- hacia el integrado MCP4921 (DAC)
library ieee;
use ieee.std_logic_1164.all;

entity SPI_MCP4921 is 
port(		clki: 	in std_logic ; 
			Reset: 	in std_logic ;
			Enable: 	in std_logic ;
			--DataIn: 	in std_logic_vector(11 downto 0); 	-- Para colocar los datos a la entrada en paralelo
			CS: 		out std_logic;
			MOSI: 	out std_logic;
			clkOut: 	out std_logic
			
		
);

end SPI_MCP4921;

architecture Arq1 of SPI_MCP4921 is
signal clkOut_A: 	std_logic := '1';
signal Config: 	std_logic_vector(3 downto 0) := "0011";   -- Bits de configuración (Primeros bits a enviar) 
signal clk_count: integer range 0 to 5;
signal clk_count_1: integer range 0 to 5;
signal C: 			integer range 0 to 15 := 3;
signal MOSI_A: 	std_logic;
signal CS_A: 		std_logic;
signal DataIn_A: 	std_logic_vector(11 downto 0) := "010101010101"; -- Señal a transmitir (12 bits)
type State_t is (Init, TransmitData, Stop);
signal State: State_t := Init;
begin
process(clki)										-- Este proceso sirve para generar la señal de reloj de salida del modulo
begin 
		
		if rising_edge(clki) then 
			if clk_count = 3 then 			-- 4 ciclos de reloj				
				clkOut_A <= not clkOut_A ; -- Invierte la señal
				clk_count <= 0 ;				-- Reinicia contador
			else 
				clk_count <= clk_count +1;
				
			end if;
			
		end if;
end process;

process(clkOut_A, Reset)
begin
		if Reset = '1' then
			CS_A <= '1';						-- Deja de transmitir
			MOSI_A <= '0';
			State <= Init;
		elsif falling_edge(clkOut_A) and Enable = '1' then 
			case State is 
				when Init => 
				   CS_A <= '0'; 					-- Coloca Chip Select en cero para comenzar a transmitir
					MOSI_A <= Config(C);			-- envia bits de configuración
					if C = 0 then 
						State <= TransmitData ;	-- Cambia de estado
						C <=  11;						-- Reinicia contador
					else 
						C <= C -1;					-- decrementa contador
					end if;
				when TransmitData => 
					MOSI_A <= DataIn_A(C); 		-- transmite los datos en dataIn
					if C = 0 then 
						State <= Stop ;			-- Cambia de estado
					   C <= 3; 						-- Reinicia Contador
					else 
						C <= C -1;					-- Incrementa contador
					end if;
				when Stop => 
					CS_A <= '1'; 					-- Coloco CS en alto (para terminar transmisión)
					MOSI_A <= '0';
					State <= Init;
				when others => null;	
			
			end case;
		end if;
end process;
--Asignación de señales:
CS 		<= CS_A ; 
MOSI 		<= MOSI_A;
ClkOut 	<= ClkOut_A;


end Arq1;