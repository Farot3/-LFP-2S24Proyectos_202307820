module analizador_lexico
    implicit none
    
    type token
        character(len=1000) :: lexema
        character(len=30) :: tipo
        integer :: fila
        integer :: columna
    end type token
    
    type error
        character(len=100) :: descripcion
        character(len=1000) :: caracter_o_palabra
        integer :: fila
        integer :: columna
    end type error
    
    integer, parameter :: MAX_TOKENS = 1000
    integer, parameter :: MAX_ERRORES = 100
    
    character(len=20), dimension(11), parameter :: palabras_reservadas = [character(len=20) :: &
        "grafica", "nombre", "continente", "pais", "poblacion", "saturacion", "bandera", ":", "{", "}", ";"]
    
contains

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
    
    estado = 0
    num_tokens = 0
    num_errores = 0
    fila = 1
    columna = 1
    lexema_actual = ""
    inicio_lexema = 1
    inicio_col = 1
    
    indice = 1
    do while (indice <= len_trim(entrada))
        c = entrada(indice:indice)
        procesar_actual = .true.
        
        select case (estado)
        case (0) ! Estado inicial
            inicio_lexema = fila
            inicio_col = columna
            if (c == '{' .or. c == '}' .or. c == ':' .or. c == ';') then
                call agregar_token(tokens, num_tokens, c, get_token_type(c), fila, columna)
            else if (c == '"') then
                estado = 1
                lexema_actual = c
            else if (es_letra_minuscula(c)) then
                estado = 2
                lexema_actual = c
            else if (es_digito(c)) then
                estado = 3
                lexema_actual = c
            else if (c == ' ' .or. c == char(9) .or. c == char(10)) then
                if (c == char(10)) then
                    fila = fila + 1
                    columna = 0
                end if
            else if (es_letra_mayuscula(c)) then
                call agregar_error(errores, num_errores, "Letra mayúscula no permitida", c, fila, columna)
            else
                call agregar_error(errores, num_errores, "Caracter no reconocido", c, fila, columna)
            end if
            
        case (1) ! Estado para cadenas
            lexema_actual = trim(lexema_actual) // c
            if (c == '"' .and. lexema_actual(len_trim(lexema_actual)-1:len_trim(lexema_actual)-1) /= '\') then
                call agregar_token(tokens, num_tokens, lexema_actual, "CADENA", inicio_lexema, inicio_col)
                estado = 0
                lexema_actual = ""
            else if (c == char(10)) then
                call agregar_error(errores, num_errores, "Cadena no cerrada", lexema_actual, inicio_lexema, inicio_col)
                estado = 0
                lexema_actual = ""
                fila = fila + 1
                columna = 0
            end if
            
        case (2) ! Estado para identificadores o palabras reservadas
            if (es_letra_minuscula(c) .or. es_digito(c) .or. c == '_') then
                lexema_actual = trim(lexema_actual) // c
            else
                if (es_palabra_reservada(lexema_actual)) then
                    call agregar_token(tokens, num_tokens, lexema_actual, "RESERVADA", inicio_lexema, inicio_col)
                else
                    call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR", inicio_lexema, inicio_col)
                end if
                estado = 0
                procesar_actual = .false.
            end if
            
        case (3) ! Estado para números
            if (es_digito(c)) then
                lexema_actual = trim(lexema_actual) // c
            else if (c == '%') then
                lexema_actual = trim(lexema_actual) // c
                call agregar_token(tokens, num_tokens, lexema_actual, "PORCENTAJE", inicio_lexema, inicio_col)
                estado = 0
                lexema_actual = ""
            else
                call agregar_token(tokens, num_tokens, lexema_actual, "NUMERO", inicio_lexema, inicio_col)
                estado = 0
                procesar_actual = .false.
            end if
        end select
        
        if (procesar_actual) then
            indice = indice + 1
            columna = columna + 1
        end if
    end do
    
    ! Procesar cualquier token pendiente al final de la entrada
    if (estado == 2) then
        if (es_palabra_reservada(lexema_actual)) then
            call agregar_token(tokens, num_tokens, lexema_actual, "RESERVADA", inicio_lexema, inicio_col)
        else
            call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR", inicio_lexema, inicio_col)
        end if
    else if (estado == 3) then
        call agregar_token(tokens, num_tokens, lexema_actual, "NUMERO", inicio_lexema, inicio_col)
    else if (estado == 1) then
        call agregar_error(errores, num_errores, "Cadena no cerrada al final del archivo", lexema_actual, inicio_lexema, inicio_col)
    end if
end subroutine analizar

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

subroutine agregar_error(errores, num_errores, descripcion, caracter_o_palabra, fila, columna)
    type(error), intent(inout) :: errores(MAX_ERRORES)
    integer, intent(inout) :: num_errores
    character(len=*), intent(in) :: descripcion, caracter_o_palabra
    integer, intent(in) :: fila, columna
    
    if (num_errores < MAX_ERRORES) then
        num_errores = num_errores + 1
        errores(num_errores)%descripcion = descripcion
        errores(num_errores)%caracter_o_palabra = caracter_o_palabra
        errores(num_errores)%fila = fila
        errores(num_errores)%columna = columna
    end if
end subroutine agregar_error

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
    case default
        tipo = "DESCONOCIDO"
    end select
end function get_token_type

function es_letra_minuscula(c) result(res)
    character, intent(in) :: c
    logical :: res
    res = (c >= 'a' .and. c <= 'z')
end function es_letra_minuscula

function es_letra_mayuscula(c) result(res)
    character, intent(in) :: c
    logical :: res
    res = (c >= 'A' .and. c <= 'Z')
end function es_letra_mayuscula

function es_digito(c) result(res)
    character, intent(in) :: c
    logical :: res
    res = (c >= '0' .and. c <= '9')
end function es_digito

function es_palabra_reservada(palabra) result(res)
    character(len=*), intent(in) :: palabra
    logical :: res
    integer :: i
    res = .false.
    do i = 1, size(palabras_reservadas)
        if (trim(palabra) == trim(palabras_reservadas(i))) then
            res = .true.
            exit
        end if
    end do
end function es_palabra_reservada

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
                trim(errores(i)%descripcion), '</td><td>', trim(errores(i)%caracter_o_palabra), '</td><td>', &
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

end module analizador_lexico

program main
    use analizador_lexico
    implicit none
    
    character(len=10000) :: entrada
    character(len=100) :: linea
    type(token) :: tokens(MAX_TOKENS)
    type(error) :: errores(MAX_ERRORES)
    integer :: num_tokens, num_errores
    integer :: io_status
    
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
    call generar_html(tokens, num_tokens, errores, num_errores)
    
    print *, "Análisis completado."
    print '(A,I0)', "Tokens identificados: ", num_tokens
    print '(A,I0)', "Errores encontrados: ", num_errores
    print *, "Resultados guardados en 'resultado_analisis.html'."
    
end program main