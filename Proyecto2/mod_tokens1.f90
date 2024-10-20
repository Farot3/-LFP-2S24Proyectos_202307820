module mod_tokens1
    implicit none
    private
    public :: Token1, LLAVE_ABRE, LLAVE_CIERRA, PUNTO_Y_COMA, PARENTESIS_ABRE, PARENTESIS_CIERRA, PUNTO, COMA, MENOR_QUE, &
    ADMIRACION, GUION, MAYOR_QUE, COMENTARIO_LINEA, COMENTARIO_MULTILINEA, CADENA, NUMERO, Palabra_clave, nombre_bloque_Controles&
    , nombre_bloque_Propiedades, nombre_bloque_Colocacion,  Propiedad_setColorLetraFondo, &
    Propiedad_setTexto, Propiedad_setAlineacion, Propiedad_setMarcada, Propiedad_setGrupo, Propiedad_setAnto, &
    Control_setPosicion, IDENTIFICADOR, ADD, THIS, TRUE_FALSE, ALINEACION

    type :: Token1 
        character(len=100) :: valor
        integer :: tipos, fila, columna
    end type Token1

    integer, parameter :: LLAVE_ABRE = 1
    integer, parameter :: LLAVE_CIERRA = 2
    integer, parameter :: PUNTO_Y_COMA = 4
    integer, parameter :: PARENTESIS_ABRE = 5
    integer, parameter :: PARENTESIS_CIERRA = 6
    integer, parameter :: PUNTO = 7
    integer, parameter :: COMA = 8
    integer, parameter :: MENOR_QUE = 10
    integer, parameter :: ADMIRACION = 11
    integer, parameter :: GUION = 12
    integer, parameter :: MAYOR_QUE = 13
    integer, parameter :: COMENTARIO_LINEA = 14
    integer, parameter :: COMENTARIO_MULTILINEA = 15
    integer, parameter :: CADENA = 16
    integer, parameter :: NUMERO = 17
    integer, parameter :: Palabra_clave = 18
    integer, parameter :: nombre_bloque_Controles = 19
    integer, parameter :: nombre_bloque_Propiedades = 20
    integer, parameter :: nombre_bloque_Colocacion = 21
    integer, parameter :: Propiedad_setColorLetraFondo = 22
    integer, parameter :: Propiedad_setTexto = 23
    integer, parameter :: Propiedad_setAlineacion = 24
    integer, parameter :: Propiedad_setMarcada = 25
    integer, parameter :: Propiedad_setGrupo = 26
    integer, parameter :: Propiedad_setAnto = 27
    integer, parameter :: Control_setPosicion = 28
    integer, parameter :: IDENTIFICADOR = 29
    integer, parameter :: ADD = 30
    integer, parameter :: THIS = 31
    integer, parameter :: TRUE_FALSE = 32 
    integer, parameter :: ALINEACION = 33

end module mod_tokens1