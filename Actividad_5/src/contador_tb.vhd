library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity contador_tb is
    -- Un testbench no tiene puertos
end contador_tb;

architecture sim of contador_tb is
    -- Declaración exacta del componente
    component contador_top
        port(
            clk    : in STD_LOGIC;
            reset  : in STD_LOGIC;
            load   : in STD_LOGIC;
            ending : in STD_LOGIC;
            D      : in STD_LOGIC_VECTOR(3 downto 0);
            Q      : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    signal clk, reset, load, ending : STD_LOGIC := '0';
    signal D, Q : STD_LOGIC_VECTOR(3 downto 0) := "0000";

begin
    -- Mapeo de puertos
    dut: contador_top port map (
        clk => clk,
        reset => reset,
        load => load,
        ending => ending,
        D => D,
        Q => Q
    );

    -- Generador de reloj continuo (sin bucles while)
    process begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;

    -- Proceso de estímulos
    process begin

         -- Inicializador del reloj
        reset <= '1';
        wait for 10 ns;
        reset <= '0';

        -- Carga el valor inicial "1"
        load <= '1';
        D <= "0001"; 
        wait for 10 ns;
        load <= '0';

        -- Habilita el conteo
        ending <= '1';

        -- Dejarlo contar hasta "15" y que vuelva a "1"
        wait for 180 ns;

        assert false report "Simulacion completada exitosamente." severity failure;

    end process;

end sim;