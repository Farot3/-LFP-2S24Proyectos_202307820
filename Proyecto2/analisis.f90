module Analizador_lexico
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

contains

    function itoa(i) result(str)
        implicit none
        integer, intent(in) :: i
        character(len=12) :: str
        write(str, '(I0)') i
    end function itoa

    subroutine analizar(entrada, tokens, num_tokens, errores, num_errores)
        character(len=*), intent(in) :: entrada
        type(token), intent(out) :: tokens(MAX_TOKENS)
        integer, intent(out) :: num_tokens
        type(error), intent(out) :: errores(MAX_ERRORES)
        integer, intent(out) :: num_errores
        
        integer :: estado, indice, fila, columna, inicio_lexema, inicio_col
        character :: c
        character(len=1000) :: lexema_actual
        logical :: procesar_actual
        logical :: dentro_bloque
        integer :: nivel_anidamiento

        estado = 0
        num_tokens = 0
        num_errores = 0
        fila = 1
        columna = 1
        lexema_actual = ""
        inicio_lexema = 1
        inicio_col = 1
        dentro_bloque = .false.
        nivel_anidamiento = 0

        indice = 1
        do while (indice <= len_trim(entrada))
            c = entrada(indice:indice)
            procesar_actual = .true.
            
            select case (estado)
            case (0) ! Estado inicial
                inicio_lexema = fila
                inicio_col = columna
                if (c == '{' .or. c == '}' .or. c == ':' .or. c == ';' .or. c == '(' .or. c == ')' .or. c == '.' .or. c == ',') then
                    call agregar_token(tokens, num_tokens, c, get_token_type(c), fila, columna)
                    if (c == '{') then
                        dentro_bloque = .true.
                        nivel_anidamiento = nivel_anidamiento + 1
                    else if (c == '}') then
                        nivel_anidamiento = nivel_anidamiento - 1
                        if (nivel_anidamiento == 0) dentro_bloque = .false.
                    end if
                else if (c == '<') then
                    estado = 1
                    lexema_actual = c
                else if (c == '-') then
                    estado = 12
                    lexema_actual = c
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
                    end if
                else
                    call agregar_error(errores, num_errores, "Caracter no reconocido", c, fila, columna, "LEXICO")
                end if
                
            case (1) ! Procesando '<!--'
                lexema_actual = trim(lexema_actual) // c
                if (len_trim(lexema_actual) == 4 .and. lexema_actual == "<!--") then
                    call agregar_token(tokens, num_tokens, lexema_actual, "INICIO_BLOQUE", inicio_lexema, inicio_col)
                    estado = 0
                    lexema_actual = ""
                else if (len_trim(lexema_actual) > 4) then
                    call agregar_error(errores, num_errores, "Se esperaba '<!--'", lexema_actual, fila, columna, "LEXICO")
                    estado = 0
                    lexema_actual = ""
                end if

            case (5) ! Procesando comentarios
                if (c == '/') then
                    estado = 6 ! Comentario de una línea
                    lexema_actual = trim(lexema_actual) // c
                else if (c == '*') then
                    estado = 10 ! Comentario de varias líneas
                    lexema_actual = trim(lexema_actual) // c
                else
                    call agregar_error(errores, num_errores, "Se esperaba '/' o '*' después de '/'", c, fila, columna, "LEXICO")
                    estado = 0
                    lexema_actual = ""
                end if

            case (6) ! Comentario de una línea
                lexema_actual = trim(lexema_actual) // c
                if (c == char(10)) then
                    call agregar_token(tokens, num_tokens, lexema_actual, "COMENTARIO_LINEA", inicio_lexema, inicio_col)
                    estado = 0
                    lexema_actual = ""
                    fila = fila + 1
                    columna = 0
                end if

            case (10) ! Comentario de varias líneas
                lexema_actual = trim(lexema_actual) // c
                if (c == '*') then
                    estado = 11
                end if

            case (11) ! Posible fin de comentario de varias líneas
                lexema_actual = trim(lexema_actual) // c
                if (c == '/') then
                    call agregar_token(tokens, num_tokens, lexema_actual, "COMENTARIO_MULTILINEA", inicio_lexema, inicio_col)
                    estado = 0
                    lexema_actual = ""
                else
                    estado = 10
                end if

            case (2) ! Estado para identificadores o palabras reservadas
                if (is_letter(c) .or. is_digit(c) .or. c == '_') then
                    lexema_actual = trim(lexema_actual) // c
                else
                    if (is_identificador_especial(lexema_actual)) then
                        call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR_" // lexema_actual, inicio_lexema, inicio_col)
                    else
                        call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR", inicio_lexema, inicio_col)
                    end if
                    estado = 0
                    procesar_actual = .false.
                end if
                
            case (3) ! Estado para números
                if (is_digit(c)) then
                    lexema_actual = trim(lexema_actual) // c
                else
                    call agregar_token(tokens, num_tokens, lexema_actual, "NUMERO", inicio_lexema, inicio_col)
                    estado = 0
                    procesar_actual = .false.
                end if

            case (12) ! Procesando '-->'
                lexema_actual = trim(lexema_actual) // c
                if (len_trim(lexema_actual) == 3 .and. lexema_actual == "-->") then
                    call agregar_token(tokens, num_tokens, lexema_actual, "FIN_BLOQUE", inicio_lexema, inicio_col)
                    estado = 0
                    lexema_actual = ""
                else if (len_trim(lexema_actual) > 3) then
                    call agregar_error(errores, num_errores, "Se esperaba '-->'", lexema_actual, fila, columna, "LEXICO")
                    estado = 0
                    lexema_actual = ""
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
                end if
            end select
            
            if (procesar_actual) then
                indice = indice + 1
                columna = columna + 1
            end if
        end do
        
        ! Procesar cualquier token pendiente al final de la entrada
        if (estado == 2) then
            if (is_identificador_especial(lexema_actual)) then
                call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR_" // lexema_actual, inicio_lexema, inicio_col)
            else
                call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR", inicio_lexema, inicio_col)
            end if
        else if (estado == 3) then
            call agregar_token(tokens, num_tokens, lexema_actual, "NUMERO", inicio_lexema, inicio_col)
        else if (estado == 6) then
            call agregar_token(tokens, num_tokens, lexema_actual, "COMENTARIO_LINEA", inicio_lexema, inicio_col)
        else if (estado == 10 .or. estado == 11) then
            call agregar_token(tokens, num_tokens, lexema_actual, "COMENTARIO_MULTILINEA", inicio_lexema, inicio_col)
        else if (estado == 1) then
            call agregar_error(errores, num_errores, "Bloque de propiedades no cerrado al final del archivo", lexema_actual, inicio_lexema, inicio_col, "LEXICO")
        else if (estado == 13) then
            call agregar_error(errores, num_errores, "Cadena no cerrada al final del archivo", lexema_actual, inicio_lexema, inicio_col, "LEXICO")
        end if
    end subroutine analizar

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
        case (':')
            tipo = "DOS_PUNTOS"
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
        case ('=')
            tipo = "IGUAL"
        case default
            tipo = "DESCONOCIDO"
        end select
    end function get_token_type

    function is_identificador_especial(lexema) result(res)
        character(len=*), intent(in) :: lexema
        logical :: res
        res = (index(lexema, "set") == 1 .or. index(lexema, "add") == 1)
    end function is_identificador_especial

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
            write(*, '(A)') "ERROR" // "|" // trim(errores(i)%tipo) // "|" // trim(errores(i)%descripcion) // "|" // trim(errores(i)%token) // "|" // trim(itoa(errores(i)%fila)) // "|" // trim(itoa(errores(i)%columna))
        end do
    end subroutine imprimir_errores

end module Analizador_lexico

program main
    use Analizador_lexico
    implicit none
    
    character(len=10000) :: entrada
    character(len=100) :: linea
    integer :: io_status
    type(token) :: tokens(MAX_TOKENS)
    type(error) :: errores(MAX_ERRORES)
    integer :: num_tokens, num_errores

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
    else
        call imprimir_tokens(tokens, num_tokens)
    end if
    
end program main