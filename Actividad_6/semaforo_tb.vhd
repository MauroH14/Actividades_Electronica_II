library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity semaforo_unica_tb is
    -- Un testbench no tiene puertos
end semaforo_unica_tb;

architecture sim of semaforo_unica_tb is
    -- Declaración del componente a probar
    component semaforo_unica
        port (
            clk, nreset, S_NS, S_EO, E_NS, E_EO, Z : in STD_LOGIC;
            L_NS, L_EO : out STD_LOGIC_VECTOR(2 downto 0);
            C, RES_NS, RES_EO : out STD_LOGIC;
            Q_max : out INTEGER
        );
    end component;

    -- Señales internas
    signal clk, S_NS, S_EO, E_NS, E_EO, Z : STD_LOGIC := '0';
    signal nreset : STD_LOGIC := '1';
    signal L_NS, L_EO : STD_LOGIC_VECTOR(2 downto 0);
    signal C, RES_NS, RES_EO : STD_LOGIC;
    signal Q_max : INTEGER;

begin
    -- Mapeo de puertos
    dut: semaforo_unica port map (
        clk => clk, nreset => nreset, S_NS => S_NS, S_EO => S_EO,
        E_NS => E_NS, E_EO => E_EO, Z => Z, L_NS => L_NS, L_EO => L_EO,
        C => C, Q_max => Q_max, RES_NS => RES_NS, RES_EO => RES_EO
    );

    -- Generador de reloj (Periodo = 10 ns)
    process begin
        clk <= '1'; wait for 5 ns;
        clk <= '0'; wait for 5 ns;
    end process;

    process begin
        -- 0. INICIALIZACIÓN
        nreset <= '0'; -- Reset activo en bajo
        wait for 15 ns;
        nreset <= '1';
        wait for 10 ns;
        -- Estado inicial esperado: RV (Rojo en NS, Verde en EO)

        -- 1. PRUEBA DE FUNCIONAMIENTO BÁSICO
        Z <= '1'; wait for 10 ns; Z <= '0'; -- Simula fin de Verde. Pasa a RA
        wait for 20 ns;
        Z <= '1'; wait for 10 ns; Z <= '0'; -- Simula fin de Amarillo. Pasa a VR
        wait for 20 ns;
        Z <= '1'; wait for 10 ns; Z <= '0'; -- Simula fin de Verde. Pasa a AR
        wait for 20 ns;
        Z <= '1'; wait for 10 ns; Z <= '0'; -- Vuelve a RV
        wait for 30 ns;

        -- 2. PRUEBA DE CASO PEATONAL
        -- Estando en RV, un peatón aprieta el botón en EO
        S_EO <= '1'; 
        wait for 10 ns;
        Z <= '1'; wait for 10 ns; Z <= '0'; -- Termina el verde normal. Pasa a RVEXT
        S_EO <= '0'; -- Soltamos el botón (se resetea con RES_EO)
        wait for 20 ns;
        Z <= '1'; wait for 10 ns; Z <= '0'; -- Termina la extensión. Pasa a RA
        wait for 20 ns;
        Z <= '1'; wait for 10 ns; Z <= '0'; -- Pasa a VR
        wait for 30 ns;

        -- 3. PRUEBA DE CASO DE EMERGENCIA
        -- Estando en VR (NS en Verde, EO en Rojo), viene ambulancia por EO
        E_EO <= '1'; -- Emergencia en la calle que está en rojo
        wait for 10 ns; 
        -- El sistema debería saltar INMEDIATAMENTE a AR (Amarillo) sin esperar a Z
        wait for 20 ns;
        Z <= '1'; wait for 10 ns; Z <= '0'; -- Termina el amarillo. Pasa a RV (EO en Verde)
        wait for 40 ns;
        E_EO <= '0';

        -- DETENER SIMULACIÓN LIMPIAMENTE
        assert false report "Simulacion completada exitosamente." severity failure;
    end process;

end sim;