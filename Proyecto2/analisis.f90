module Analizador_lexico
    use mod_tokens1
    implicit none

    type token
        character(len=1000) :: tipo
        character(len=1000) :: lexema
        integer :: ID
        integer :: fila
        integer :: columna
    end type token

    type error 
        character(len=1000) :: tipo
        character(len=100) :: descripcion
        character(len=1000) :: token
        integer :: fila
        integer :: columna
    end type error

    integer, parameter :: MAX_TOKENS = 1000
    integer, parameter :: MAX_ERRORES = 1000

    character(len=20), dimension(8), parameter :: PALABRAS_CLAVE = [character(len=20) :: &
        "Contenedor", "Texto", "Etiqueta", "Clave", "Boton", "Check", "RadioBoton", "AreaTexto" &
    ]

contains

    function itoa(i) result(str)
        implicit none
        integer, intent(in) :: i
        character(len=12) :: str
        write(str, '(I0)') i
    end function itoa

    subroutine escanear(entrada, listaTokens)
        character(len=*), intent(inout) :: entrada
        ! Variable que representa la lista de tokens
        type(token1), dimension(:), allocatable, intent(out) :: listaTokens
        ! Variable que representa el estado actual
        integer :: i, estado, length, fila, columna, inicio_lexema, inicio_col
        character(len=1) :: c
        ! Variable que representa el lexema que actualmente se esta acumulando
        character(len=100) :: auxLex
        logical :: procesar_actual
    
        ! Inicialización
        length = len_trim(entrada)
        estado = 0
        auxLex = ""
        i = 0
        fila = 1
        columna = 1
        inicio_lexema = 1
        inicio_col = 1
        allocate(listaTokens(0)) ! Inicializar el array de tokens vacío
    
        ! Le agrego caracter de fin de cadena porque hay lexemas que aceptan con 
        ! el primer caracter del siguiente lexema y si este caracter no existe entonces
        ! perdemos el lexema
        entrada(length + 1: length + 1) = '#'
        length = length + 1
    
        ! Ciclo que recorre de izquierda a derecha caracter por caracter la cadena de entrada
        do while (i <= length)
            i = i + 1
            c = entrada(i:i)
            procesar_actual = .true.
    
            ! Select en el que cada caso representa cada uno de los estados del conjunto de estados
            select case (estado)
            case (0)
                inicio_lexema = fila
                inicio_col = columna
                if (c >= '0' .and. c <= '9') then
                    estado = 1
                    auxLex = trim(auxLex) // c
                else if (c == '/') then
                    estado = 5
                    auxLex = c
                else if (c == '"') then
                    estado = 13
                    auxLex = c
                else if (is_letter(c)) then
                    estado = 2
                    auxLex = c      
                else if (c == ';') then
                    auxLex = c
                    call addToken(PUNTO_Y_COMA, auxLex, fila, columna, listaTokens)
                else if (c == '(') then
                    auxLex = c
                    call addToken(PARENTESIS_ABRE, auxLex, fila, columna, listaTokens)
                else if (c == ')') then
                    auxLex = c
                    call addToken(PARENTESIS_CIERRA, auxLex, fila, columna, listaTokens)
                else if(c == '.') then
                    auxLex = c
                    call addToken(PUNTO, auxLex, fila, columna, listaTokens)
                else if(c == ',') then
                    auxLex = c
                    call addToken(COMA, auxLex, fila, columna, listaTokens)
                else if(c == '<') then
                    auxLex = c
                    call addToken(MENOR_QUE, auxLex, fila, columna, listaTokens)
                else if(c == '!') then
                    auxLex = c 
                    call addToken(ADMIRACION, auxLex, fila, columna, listaTokens)
                else if(c == '-') then
                    auxLex = c 
                    call addToken(GUION, auxLex, fila, columna, listaTokens)
                else if(c == '>') then
                    auxLex = c
                    call addToken(MAYOR_QUE, auxLex, fila, columna, listaTokens)
                else if (c == '#' .and. i == length) then
                    print *, "Hemos concluido el analisis lexico satisfactoriamente"
                    exit
                else if (c == char(10)) then
                    fila = fila + 1
                    columna = 1
                    procesar_actual = .false.
                else
                    estado = 0
                end if
            case (1) !Estado para números
                if (c >= '0' .and. c <= '9') then
                    estado = 1
                    auxLex = trim(auxLex) // c
                else
                    call addToken(NUMERO, auxLex, fila, columna, listaTokens)
                    i = i - 1
                    estado = 0
                    procesar_actual = .false.
                end if
            case (2) ! Estado para identificadores o palabras reservadas
                if (is_letter(c) .or. is_digit(c) .or. c == '_') then
                    auxLex = trim(auxLex) // c
                else
                    if (trim(auxLex) == "Contenedor") then
                        call addToken(Palabra_clave, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "Texto") then
                        call addToken(Palabra_clave, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "Clave") then
                        call addToken(Palabra_clave, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "Boton") then
                        call addToken(Palabra_clave, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "Check") then
                        call addToken(Palabra_clave, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "RadioBoton") then
                        call addToken(Palabra_clave, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "AreaTexto") then
                        call addToken(Palabra_clave, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "Etiqueta") then
                        call addToken(Palabra_clave, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "add") then
                        call addToken(ADD, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "this") then
                        call addToken(THIS, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "Controles") then
                        call addToken(nombre_bloque_Controles, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "Propiedades") then
                        call addToken(nombre_bloque_Propiedades, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "Colocacion") then
                        call addToken(nombre_bloque_Colocacion, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "setColorLetra")then
                        call addToken(Propiedad_setColorLetraFondo, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "setTexto")then
                        call addToken(Propiedad_setTexto, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "setAlineacion")then
                        call addToken(Propiedad_setAlineacion, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "setColorFondo")then
                        call addToken(Propiedad_setColorLetraFondo, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "setMarcada")then
                        call addToken(Propiedad_setMarcada, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "setGrupo")then
                        call addToken(Propiedad_setGrupo, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "setAncho")then
                        call addToken(Propiedad_setAnto, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "setAlto")then
                        call addToken(Propiedad_setAnto, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "setPosicion")then
                        call addToken(Control_setPosicion, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "true") then
                        call addToken(TRUE_FALSE, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "false") then
                        call addToken(TRUE_FALSE, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "derecho") then
                        call addToken(ALINEACION, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "izquierdo") then
                        call addToken(ALINEACION, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else if (trim(auxLex) == "centro") then
                        call addToken(ALINEACION, auxLex, inicio_lexema, inicio_col, listaTokens)
                    else
                        call addToken(IDENTIFICADOR, auxLex, inicio_lexema, inicio_col, listaTokens)
                    end if
                    estado = 0
                    i = i - 1
                    procesar_actual = .false.
                end if
            case (5) ! Estado para procesar comentarios
                if (c == '/') then
                    estado = 6 ! Estado para comentario de una línea
                    auxLex = trim(auxLex) // c
                else if (c == '*') then
                    estado = 10 ! Estado para comentario de varias líneas
                    auxLex = trim(auxLex) // c
                else
                    estado = 0
                    auxLex = ""
                end if
    
            case (6) ! Estado para comentario de una línea
                auxLex = trim(auxLex) // c
                if (c == char(10)) then
                    call addToken(COMENTARIO_LINEA, auxLex, inicio_lexema, inicio_col, listaTokens)
                    estado = 0
                    auxLex = ""
                    fila = fila + 1
                    columna = 1
                    procesar_actual = .false.
                end if
    
            case (10) ! Estado para comentario de varias líneas
                auxLex = trim(auxLex) // c
                if (c == '*') then
                    estado = 11 ! Estado para posible fin de comentario de varias líneas
                else if (c == char(10)) then
                    fila = fila + 1
                    columna = 1
                end if
    
            case (11) ! Estado para posible fin de comentario de varias líneas
                auxLex = trim(auxLex) // c
                if (c == '/') then
                    call addToken(COMENTARIO_MULTILINEA, auxLex, inicio_lexema, inicio_col, listaTokens)
                    estado = 0
                    auxLex = ""
                else if (c == char(10)) then
                    fila = fila + 1
                    columna = 1
                    estado = 10
                else
                    estado = 10
                end if
    
            case (13) ! Estado para cadenas
                auxLex = trim(auxLex) // c
                if (c == '"' .and. auxLex(len_trim(auxLex)-1:len_trim(auxLex)-1) /= '\') then
                    call addToken(CADENA, auxLex, inicio_lexema, inicio_col, listaTokens)
                    estado = 0
                    auxLex = ""
                else if (c == char(10)) then
                    estado = 0
                    auxLex = ""
                    fila = fila + 1
                    columna = 1
                    procesar_actual = .false.
                end if
            end select
    
            if (procesar_actual) then
                columna = columna + 1
            end if
        end do
    end subroutine escanear

    subroutine analizar(entrada, tokens, num_tokens, errores, num_errores)
        character(len=*), intent(in) :: entrada
        type(token), intent(out) :: tokens(MAX_TOKENS)
        integer, intent(out) :: num_tokens
        type(error), intent(out) :: errores(MAX_ERRORES)
        integer, intent(out) :: num_errores
        
        integer :: estado, indice, fila, columna, inicio_lexema, inicio_col, nivel_anidamiento
        integer :: i, length
        character :: c
        character(len=1000) :: lexema_actual
        logical :: procesar_actual, inicio_linea
    
        estado = 0
        num_tokens = 0
        num_errores = 0
        fila = 1
        columna = 1
        lexema_actual = ""
        inicio_lexema = 1
        inicio_col = 1
        nivel_anidamiento = 0
        inicio_linea = .true.
    
        indice = 1
        length = len_trim(entrada)
        do while (indice <= length)
            c = entrada(indice:indice)
            procesar_actual = .true.
            
            select case (estado)
            case (0) ! Estado inicial
                inicio_lexema = fila
                inicio_col = columna
                if (c == ';' .or. c == '(' .or. c == ')' .or. c == '.' .or. c == ',') then
                    call agregar_token(tokens, num_tokens, c, get_token_type(c), fila, columna)
                else if (c == '<' .or. c == '!' .or. c == '-' .or. c == '>') then
                    call agregar_token(tokens, num_tokens, c, get_token_type(c), fila, columna)
                else if (c == '/') then
                    estado = 5
                    lexema_actual = c
                else if (c == '"') then
                    estado = 13
                    lexema_actual = c
                else if (is_letter(c)) then
                    estado = 2
                    lexema_actual = c
                else if (is_digit(c)) then
                    estado = 3
                    lexema_actual = c
                else if (c == ' ' .or. c == char(9) .or. c == char(10)) then
                    if (c == char(10)) then
                        fila = fila + 1
                        columna = 0
                        inicio_linea = .true.
                    end if
                else
                    call agregar_error(errores, num_errores, "Caracter no reconocido", c, fila, columna, "LEXICO")
                    c = ' '
                end if
    
            case (2) ! Estado para identificadores o palabras reservadas
                if (is_letter(c) .or. is_digit(c) .or. c == '_') then
                    lexema_actual = trim(lexema_actual) // c
                else
                    if (inicio_linea .and. is_palabra_clave_exacta(lexema_actual)) then
                        call agregar_token(tokens, num_tokens, lexema_actual, "Palabra_clave", inicio_lexema, inicio_col)
                    else if (inicio_linea .and. is_palabra_clave(lexema_actual)) then
                        call agregar_error(errores, num_errores, "Se esperaba una palabra clave exacta", lexema_actual, inicio_lexema, inicio_col, "LEXICO")
                    else if (is_identificador_especial(lexema_actual)) then
                        call agregar_token(tokens, num_tokens, lexema_actual, "Propiedad_" // trim(lexema_actual), inicio_lexema, inicio_col)
                    else if (is_identificador_add(lexema_actual)) then
                        call agregar_token(tokens, num_tokens, lexema_actual, "ADD", inicio_lexema, inicio_col)
                    else if (is_identificador_this(lexema_actual)) then
                        call agregar_token(tokens, num_tokens, lexema_actual, "THIS", inicio_lexema, inicio_col)
                    else if (lexema_actual == "Controles" .or. lexema_actual == "Propiedades" .or. lexema_actual == "Colocacion") then
                        call agregar_token(tokens, num_tokens, lexema_actual, "nombre_bloque_" // trim(lexema_actual), inicio_lexema, inicio_col)
                    else if (is_identificador_Parametro(lexema_actual)) then
                        call agregar_token(tokens, num_tokens, lexema_actual, "TRUE_FALSE", inicio_lexema, inicio_col)                 
                    else if (is_identificador_Alineacion(lexema_actual)) then
                        call agregar_token(tokens, num_tokens, lexema_actual, "ALINEACION", inicio_lexema, inicio_col)
                    else if (lexema_actual == "setPosicion")then
                        call agregar_token(tokens, num_tokens, lexema_actual, "Control_setPosicion", inicio_lexema, inicio_col)
                    else
                        call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR", inicio_lexema, inicio_col)
                    end if
                    estado = 0
                    procesar_actual = .false.
                    inicio_linea = .false.
                end if
                
            case (3) ! Estado para números
                if (is_digit(c)) then
                    lexema_actual = trim(lexema_actual) // c
                else
                    call agregar_token(tokens, num_tokens, lexema_actual, "NUMERO", inicio_lexema, inicio_col)
                    estado = 0
                    procesar_actual = .false.
                end if
    
            case (5) ! Estado para procesar comentarios
                if (c == '/') then
                    estado = 6 ! Estado para comentario de una línea
                    lexema_actual = trim(lexema_actual) // c
                else if (c == '*') then
                    estado = 10 ! Estado para comentario de varias líneas
                    lexema_actual = trim(lexema_actual) // c
                else
                    call agregar_error(errores, num_errores, "Se esperaba '/' o '*' después de '/'", c, fila, columna, "LEXICO")
                    estado = 0
                    lexema_actual = ""
                end if
    
            case (6) ! Estado para comentario de una línea
                lexema_actual = trim(lexema_actual) // c
                if (c == char(10)) then
                    call agregar_token(tokens, num_tokens, lexema_actual, "COMENTARIO_LINEA", inicio_lexema, inicio_col)
                    estado = 0
                    lexema_actual = ""
                    fila = fila + 1
                    columna = 0
                    inicio_linea = .true.
                end if
    
            case (10) ! Estado para comentario de varias líneas
                lexema_actual = trim(lexema_actual) // c
                if (c == '*') then
                    estado = 11 ! Estado para posible fin de comentario de varias líneas
                else if (c == char(10)) then
                    fila = fila + 1
                    columna = 0
                end if
            
            case (11) ! Estado para posible fin de comentario de varias líneas
                lexema_actual = trim(lexema_actual) // c
                if (c == '/') then
                    call agregar_token(tokens, num_tokens, lexema_actual, "COMENTARIO_MULTILINEA", inicio_lexema, inicio_col)
                    estado = 0
                    lexema_actual = ""
                else if (c == char(10)) then
                    fila = fila + 1
                    columna = 0
                    estado = 10
                else
                    estado = 10
                end if
    
            case (13) ! Estado para cadenas
                lexema_actual = trim(lexema_actual) // c
                if (c == '"' .and. lexema_actual(len_trim(lexema_actual)-1:len_trim(lexema_actual)-1) /= '\') then
                    call agregar_token(tokens, num_tokens, lexema_actual, "CADENA", inicio_lexema, inicio_col)
                    estado = 0
                    lexema_actual = ""
                else if (c == char(10)) then
                    call agregar_error(errores, num_errores, "Cadena no cerrada", lexema_actual, inicio_lexema, inicio_col, "LEXICO")
                    estado = 0
                    lexema_actual = ""
                    fila = fila + 1
                    columna = 0
                    inicio_linea = .true.
                else if (i == length) then
                    call agregar_error(errores, num_errores, "Cadena no cerrada", lexema_actual, inicio_lexema, inicio_col, "LEXICO")
                    estado = 0
                    lexema_actual = ""
                end if
            end select
            
            if (procesar_actual) then
                indice = indice + 1
                columna = columna + 1
            end if
        end do
        
        ! Procesar cualquier token pendiente al final de la entrada
        if (estado == 2) then
            if (inicio_linea .and. is_palabra_clave_exacta(lexema_actual)) then
                call agregar_token(tokens, num_tokens, lexema_actual, "Palabra_clave", inicio_lexema, inicio_col)
            else if (inicio_linea .and. is_palabra_clave(lexema_actual)) then
                call agregar_error(errores, num_errores, "Se esperaba una palabra clave exacta", lexema_actual, inicio_lexema, inicio_col, "LEXICO")
            else if (is_identificador_especial(lexema_actual)) then
                call agregar_token(tokens, num_tokens, lexema_actual, "Propiedad_" // trim(lexema_actual), inicio_lexema, inicio_col)
            else if (is_identificador_add(lexema_actual)) then
                call agregar_token(tokens, num_tokens, lexema_actual, "ADD", inicio_lexema, inicio_col)
            else if (is_identificador_this(lexema_actual)) then
                call agregar_token(tokens, num_tokens, lexema_actual, "THIS", inicio_lexema, inicio_col)
            else if (lexema_actual == "Controles" .or. lexema_actual == "Propiedades" .or. lexema_actual == "Colocacion") then
                call agregar_token(tokens, num_tokens, lexema_actual, "nombre_bloque_" // trim(lexema_actual), inicio_lexema, inicio_col)
            else if (is_identificador_Parametro(lexema_actual)) then
                call agregar_token(tokens, num_tokens, lexema_actual, "TRUE_FALSE", inicio_lexema, inicio_col)
            else if (is_identificador_Alineacion(lexema_actual)) then
                call agregar_token(tokens, num_tokens, lexema_actual, "ALINEACION", inicio_lexema, inicio_col)
            else if (lexema_actual == "setPosicion")then
                call agregar_token(tokens, num_tokens, lexema_actual, "Control_setPosicion", inicio_lexema, inicio_col)
            else
                call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR", inicio_lexema, inicio_col)
            end if
        else if (estado == 3) then
            call agregar_token(tokens, num_tokens, lexema_actual, "NUMERO", inicio_lexema, inicio_col)
        else if (estado == 6) then
            call agregar_token(tokens, num_tokens, lexema_actual, "COMENTARIO_LINEA", inicio_lexema, inicio_col)
        else if (estado == 10 .or. estado == 11) then
            call agregar_error(errores, num_errores, "Se esperaba '*/' para cerrar el comentario", lexema_actual, inicio_lexema, inicio_col, "LEXICO")
        else if (estado == 13) then
            call agregar_error(errores, num_errores, "Cadena no cerrada", lexema_actual, inicio_lexema, inicio_col, "LEXICO")
        end if
    end subroutine analizar

    subroutine addToken(tipos, valor, fila, columna, listaTokens)
        integer, intent(in) :: tipos
        character(len=*), intent(inout) :: valor
        integer, intent(in) :: fila, columna
        type(token1), dimension(:), allocatable, intent(inout) :: listaTokens
        type(token1) :: nuevoToken
        type(token1), dimension(:), allocatable :: tempTokens
        integer :: tamanoActual

        nuevoToken%tipos = tipos
        nuevoToken%valor = valor
        nuevoToken%fila = fila
        nuevoToken%fila = columna

        tamanoActual = size(listaTokens)
    
        ! Redimensionar la lista de tokens para agregar uno nuevo
        allocate(tempTokens(tamanoActual + 1))
    
        ! Copiar los tokens actuales a la nueva lista
        if ( tamanoActual > 0 ) then
            tempTokens(1:tamanoActual) = listaTokens
        end if
    
        ! Añadir el token a la lista de tokens
        tempTokens(tamanoActual + 1) = nuevoToken
    
        ! Transferir la nueva lista a la lista de tokens
        call move_alloc(tempTokens, listaTokens)
    
        ! Limpieza
        valor = ""
    end subroutine addToken

    subroutine imprimir_lista_tokens(listaTokens)
        type(token1), dimension(:), allocatable, intent(in) :: listaTokens
        integer :: i

        print *, "Lista de Tokens:"
        do i = 1, size(listaTokens)
            print *, "Token ", i, ": Tipo= ", trim(itoa(listaTokens(i)%tipos)), ", Valor= ", trim(listaTokens(i)%valor), ", Fila= ", trim(itoa(listaTokens(i)%fila)), ", columna= ", trim(itoa(listaTokens(i)%columna))
        end do
    end subroutine imprimir_lista_tokens

    ! Funciones auxiliares
    function is_letter(c) result(res)
        character, intent(in) :: c
        logical :: res
        res = (c >= 'a' .and. c <= 'z') .or. (c >= 'A' .and. c <= 'Z')
    end function is_letter

    function is_digit(c) result(res)
        character, intent(in) :: c
        logical :: res
        res = (c >= '0' .and. c <= '9')
    end function is_digit

    function get_token_type(c) result(tipo)
        character, intent(in) :: c
        character(len=20) :: tipo
        
        select case (c)
        case ('{')
            tipo = "LLAVE_ABRE"
        case ('}')
            tipo = "LLAVE_CIERRA"
        case (';')
            tipo = "PUNTO_Y_COMA"
        case ('(')
            tipo = "PARENTESIS_ABRE"
        case (')')
            tipo = "PARENTESIS_CIERRA"
        case ('.')
            tipo = "PUNTO"
        case (',')
            tipo = "COMA"
        case ('<')
            tipo = "MENOR_QUE"
        case ('!')
            tipo = "ADMIRACION"
        case ('-')
            tipo = "GUION"
        case ('>')
            tipo = "MAYOR_QUE"
        case default
            tipo = "DESCONOCIDO"
        end select
    end function get_token_type

    function is_identificador_especial(lexema) result(res)
        character(len=*), intent(in) :: lexema
        logical :: res
        res = (lexema == "setColorLetra" .or. lexema == "setTexto" .or. lexema == "setAlineacion" .or. lexema == "setColorFondo" .or. lexema == "setMarcada" .or. lexema == "setGrupo" .or. lexema == "setAncho" .or. lexema == "setAlto")
    end function is_identificador_especial

    function is_identificador_add(lexema) result(res)
        character(len=*), intent(in) :: lexema
        logical :: res
        res = (lexema == "add")
    end function is_identificador_add

    function is_identificador_this(lexema) result(res)
        character(len=*), intent(in) :: lexema
        logical :: res
        res = (lexema == "this")
    end function is_identificador_this

    function is_identificador_Parametro(lexema) result(res)
        character(len=*), intent(in) :: lexema
        logical :: res
        res = (lexema == "true" .or. lexema == "false")
    end function is_identificador_Parametro

    function is_identificador_Alineacion(lexema) result(res)
        character(len=*), intent(in) :: lexema
        logical :: res
        res = (lexema == "derecho" .or. lexema == "izquierdo" .or. lexema == "centro")
    end function is_identificador_Alineacion

    function is_palabra_clave(lexema) result(res)
        character(len=*), intent(in) :: lexema
        logical :: res
        integer :: i
        res = .false.
        do i = 1, size(PALABRAS_CLAVE)
            if (trim(adjustl(lexema)) == trim(adjustl(PALABRAS_CLAVE(i)))) then
                res = .true.
                exit
            end if
        end do
    end function is_palabra_clave
    
    function is_palabra_clave_exacta(lexema) result(res)
        character(len=*), intent(in) :: lexema
        logical :: res
        integer :: i
        res = .false.
        do i = 1, size(PALABRAS_CLAVE)
            if (trim(adjustl(lexema)) == trim(adjustl(PALABRAS_CLAVE(i)))) then
                res = .true.
                exit
            end if
        end do
    end function is_palabra_clave_exacta

    subroutine agregar_token(tokens, num_tokens, lexema, tipo, fila, columna)
        type(token), intent(inout) :: tokens(MAX_TOKENS)
        integer, intent(inout) :: num_tokens
        character(len=*), intent(in) :: lexema, tipo
        integer, intent(in) :: fila, columna
        
        if (num_tokens < MAX_TOKENS) then
            num_tokens = num_tokens + 1
            tokens(num_tokens)%lexema = lexema
            tokens(num_tokens)%tipo = tipo
            tokens(num_tokens)%fila = fila
            tokens(num_tokens)%columna = columna
        end if
    end subroutine agregar_token

    subroutine agregar_error(errores, num_errores, descripcion, token, fila, columna, tipo)
        type(error), intent(inout) :: errores(MAX_ERRORES)
        integer, intent(inout) :: num_errores
        character(len=*), intent(in) :: descripcion, token, tipo
        integer, intent(in) :: fila, columna
        
        if (num_errores < MAX_ERRORES) then
            num_errores = num_errores + 1
            errores(num_errores)%tipo = tipo
            errores(num_errores)%fila = fila
            errores(num_errores)%columna = columna
            errores(num_errores)%token = token
            errores(num_errores)%descripcion = descripcion

        end if
    end subroutine agregar_error

    subroutine imprimir_tokens(tokens, num_tokens)
        type(token), intent(in) :: tokens(MAX_TOKENS)
        integer, intent(in) :: num_tokens
        integer :: i
    
        do i = 1, num_tokens
            write(*, '(A)') "TOKEN" // "|" // trim(tokens(i)%tipo) // "|" // trim(tokens(i)%lexema) // "|" // trim(itoa(tokens(i)%fila)) // "|" // trim(itoa(tokens(i)%columna))
        end do
    end subroutine imprimir_tokens
    
    subroutine imprimir_errores(errores, num_errores)
        type(error), intent(in) :: errores(MAX_ERRORES)
        integer, intent(in) :: num_errores
        integer :: i
    
        do i = 1, num_errores
            write(*, '(A)') "ERROR" // "|" // trim(errores(i)%tipo) // "|" // trim(adjustl(errores(i)%descripcion(1:min(len_trim(errores(i)%descripcion), 7)))) // "|" // trim(errores(i)%token) // "|" // trim(itoa(errores(i)%fila)) // "|" // trim(itoa(errores(i)%columna))
        end do
    end subroutine imprimir_errores

    subroutine generar_html(tokens, num_tokens, errores, num_errores)
        type(token), intent(in) :: tokens(MAX_TOKENS)
        integer, intent(in) :: num_tokens
        type(error), intent(in) :: errores(MAX_ERRORES)
        integer, intent(in) :: num_errores
        integer :: i, unidad
        
        open(newunit=unidad, file='resultado_analisis.html', status='replace')
        
        write(unidad, '(A)') '<!DOCTYPE html>'
        write(unidad, '(A)') '<html lang="es">'
        write(unidad, '(A)') '<head>'
        write(unidad, '(A)') '    <meta charset="UTF-8">'
        write(unidad, '(A)') '    <meta name="viewport" content="width=device-width, initial-scale=1.0">'
        write(unidad, '(A)') '    <title>Resultado del Análisis Léxico</title>'
        write(unidad, '(A)') '    <style>'
        write(unidad, '(A)') '        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }'
        write(unidad, '(A)') '        h1 { color: #333; }'
        write(unidad, '(A)') '        table { border-collapse: collapse; width: 100%; margin-top: 20px; }'
        write(unidad, '(A)') '        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }'
        write(unidad, '(A)') '        th { background-color: #f2f2f2; }'
        write(unidad, '(A)') '        .error { background-color: #ffdddd; }'
        write(unidad, '(A)') '    </style>'
        write(unidad, '(A)') '</head>'
        write(unidad, '(A)') '<body>'
        write(unidad, '(A)') '    <h1>Resultado del Análisis Léxico</h1>'
        
        if (num_errores > 0) then
            write(unidad, '(A)') '    <h2>Errores Encontrados</h2>'
            write(unidad, '(A)') '    <table>'
            write(unidad, '(A)') '        <tr><th>No</th><th>Descripción</th><th>Caracter o Palabra</th><th>Fila</th><th>Columna</th></tr>'
            do i = 1, num_errores
                write(unidad, '(A,I0,A,A,A,A,A,I0,A,I0,A)') '        <tr class="error"><td>', i, '</td><td>', &
                    trim(errores(i)%descripcion), '</td><td>', trim(errores(i)%token), '</td><td>', &
                    errores(i)%fila, '</td><td>', errores(i)%columna, '</td></tr>'
            end do
            write(unidad, '(A)') '    </table>'
        else
            write(unidad, '(A)') '    <h2>Tokens Identificados</h2>'
            write(unidad, '(A)') '    <table>'
            write(unidad, '(A)') '        <tr><th>No</th><th>Lexema</th><th>Tipo</th><th>Fila</th><th>Columna</th></tr>'
            do i = 1, num_tokens
                write(unidad, '(A,I0,A,A,A,A,A,I0,A,I0,A)') '        <tr><td>', i, '</td><td>', &
                    trim(tokens(i)%lexema), '</td><td>', trim(tokens(i)%tipo), '</td><td>', &
                    tokens(i)%fila, '</td><td>', tokens(i)%columna, '</td></tr>'
            end do
            write(unidad, '(A)') '    </table>'
        end if
        
        write(unidad, '(A)') '</body>'
        write(unidad, '(A)') '</html>'
        
        close(unidad)
    end subroutine generar_html

end module Analizador_lexico


program main
    use Analizador_lexico
    use mod_tokens1
    use mod_analizadorsintactico
    implicit none

    character(len=10000) :: entrada
    character(len=100) :: linea
    integer :: io_status
    type(token) :: tokens(MAX_TOKENS)
    type(error) :: errores(MAX_ERRORES)
    integer :: num_tokens, num_errores
    type(token1), dimension(:), allocatable :: listaTokens

    entrada = ""
    
    do
        read(*, '(A)', iostat=io_status) linea
        if (io_status /= 0) exit
        entrada = trim(entrada) // trim(linea) // char(10)
    end do

    if (len_trim(entrada) == 0) then
        print *, "Error: No se recibió contenido para analizar."
        stop
    end if
    
    call analizar(entrada, tokens, num_tokens, errores, num_errores)

    if(num_errores > 0)then
        call imprimir_errores(errores, num_errores)
        call escanear(entrada, listaTokens)
        call generar_html(tokens, num_tokens, errores, num_errores)
        call parsear1(listaTokens)
    else
        call escanear(entrada, listaTokens)
        call imprimir_tokens(tokens, num_tokens)
        call imprimir_lista_tokens(listaTokens)
        call generar_html(tokens, num_tokens, errores, num_errores)
        call parsear1(listaTokens)
    end if
    
end program main