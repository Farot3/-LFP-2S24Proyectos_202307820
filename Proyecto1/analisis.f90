module analizador_lexico
    implicit none
    
    type token
        character(len=100) :: lexema
        character(len=20) :: tipo
        integer :: fila
        integer :: columna
    end type token
    
    type error
        character(len=100) :: descripcion
        character(len=100) :: caracter_o_palabra
        integer :: fila
        integer :: columna
    end type error
    
    integer, parameter :: MAX_TOKENS = 1000
    integer, parameter :: MAX_ERRORES = 100
    
    character(len=20), dimension(7), parameter :: palabras_reservadas = [character(len=20) :: &
        "grafica", "nombre", "continente", "pais", "poblacion", "saturacion", "bandera"]
    
contains

subroutine analizar(entrada, tokens, num_tokens, errores, num_errores)
    character(len=*), intent(in) :: entrada
    type(token), intent(out) :: tokens(MAX_TOKENS)
    integer, intent(out) :: num_tokens
    type(error), intent(out) :: errores(MAX_ERRORES)
    integer, intent(out) :: num_errores
    
    integer :: estado, indice, fila, columna
    character :: c
    character(len=100) :: lexema_actual
    logical :: procesar_actual
    
    estado = 0
    num_tokens = 0
    num_errores = 0
    fila = 1
    columna = 1
    lexema_actual = ""
    
    indice = 1
    do while (indice <= len_trim(entrada))
        c = entrada(indice:indice)
        procesar_actual = .true.
        
        select case (estado)
        case (0) ! Estado inicial
            if (c == '{') then
                call agregar_token(tokens, num_tokens, "{", "LLAVE_ABRE", fila, columna)
            else if (c == '}') then
                call agregar_token(tokens, num_tokens, "}", "LLAVE_CIERRA", fila, columna)
            else if (c == ':') then
                call agregar_token(tokens, num_tokens, ":", "DOS_PUNTOS", fila, columna)
            else if (c == ';') then
                call agregar_token(tokens, num_tokens, ";", "PUNTO_Y_COMA", fila, columna)
            else if (c == '"') then
                estado = 1
                lexema_actual = c
            else if (es_letra(c)) then
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
            else if (c == '%') then
                call agregar_token(tokens, num_tokens, "%", "PORCENTAJE", fila, columna)
            else
                call agregar_error(errores, num_errores, "Caracter no reconocido", c, fila, columna)
            end if
            
        case (1) ! Estado para cadenas
            lexema_actual = lexema_actual // c
            if (c == '"') then
                call agregar_token(tokens, num_tokens, lexema_actual, "CADENA", fila, columna - len(lexema_actual) + 1)
                estado = 0
                lexema_actual = ""
            else if (c == char(10)) then
                call agregar_error(errores, num_errores, "Cadena no cerrada", lexema_actual, fila, columna)
                estado = 0
                lexema_actual = ""
                fila = fila + 1
                columna = 0
            end if
            
        case (2) ! Estado para identificadores o palabras reservadas
            if (es_letra(c) .or. es_digito(c)) then
                lexema_actual = lexema_actual // c
            else
                if (es_palabra_reservada(lexema_actual)) then
                    call agregar_token(tokens, num_tokens, lexema_actual, "RESERVADA", fila, columna - len(lexema_actual))
                else
                    if (es_palabra_reservada_case_insensitive(lexema_actual)) then
                        call agregar_error(errores, num_errores, "Palabra reservada con mayúsculas incorrectas", lexema_actual, fila, columna - len(lexema_actual))
                    else
                        call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR", fila, columna - len(lexema_actual))
                    end if
                end if
                estado = 0
                procesar_actual = .false.
                lexema_actual = ""
            end if
            
        case (3) ! Estado para números
            if (es_digito(c)) then
                lexema_actual = lexema_actual // c
            else if (c == '%') then
                lexema_actual = lexema_actual // c
                call agregar_token(tokens, num_tokens, lexema_actual, "PORCENTAJE", fila, columna - len(lexema_actual) + 1)
                estado = 0
                lexema_actual = ""
            else
                call agregar_token(tokens, num_tokens, lexema_actual, "NUMERO", fila, columna - len(lexema_actual))
                estado = 0
                procesar_actual = .false.
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
        if (es_palabra_reservada(lexema_actual)) then
            call agregar_token(tokens, num_tokens, lexema_actual, "RESERVADA", fila, columna - len(lexema_actual))
        else
            if (es_palabra_reservada_case_insensitive(lexema_actual)) then
                call agregar_error(errores, num_errores, "Palabra reservada con mayúsculas incorrectas", lexema_actual, fila, columna - len(lexema_actual))
            else
                call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR", fila, columna - len(lexema_actual))
            end if
        end if
    else if (estado == 3) then
        call agregar_token(tokens, num_tokens, lexema_actual, "NUMERO", fila, columna - len(lexema_actual))
    end if
end subroutine analizar

subroutine agregar_token(tokens, num_tokens, lexema, tipo, fila, columna)
    type(token), intent(inout) :: tokens(MAX_TOKENS)
    integer, intent(inout) :: num_tokens
    character(len=*), intent(in) :: lexema, tipo
    integer, intent(in) :: fila, columna
    
    num_tokens = num_tokens + 1
    tokens(num_tokens)%lexema = lexema
    tokens(num_tokens)%tipo = tipo
    tokens(num_tokens)%fila = fila
    tokens(num_tokens)%columna = columna
end subroutine agregar_token

subroutine agregar_error(errores, num_errores, descripcion, caracter_o_palabra, fila, columna)
    type(error), intent(inout) :: errores(MAX_ERRORES)
    integer, intent(inout) :: num_errores
    character(len=*), intent(in) :: descripcion, caracter_o_palabra
    integer, intent(in) :: fila, columna
    
    num_errores = num_errores + 1
    errores(num_errores)%descripcion = descripcion
    errores(num_errores)%caracter_o_palabra = caracter_o_palabra
    errores(num_errores)%fila = fila
    errores(num_errores)%columna = columna
end subroutine agregar_error

function es_letra(c) result(res)
    character, intent(in) :: c
    logical :: res
    res = (c >= 'a' .and. c <= 'z') .or. (c >= 'A' .and. c <= 'Z')
end function es_letra

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

function es_palabra_reservada_case_insensitive(palabra) result(res)
    character(len=*), intent(in) :: palabra
    logical :: res
    integer :: i
    res = .false.
    do i = 1, size(palabras_reservadas)
        if (trim(to_lower(palabra)) == trim(palabras_reservadas(i))) then
            res = .true.
            exit
        end if
    end do
end function es_palabra_reservada_case_insensitive

function to_lower(str) result(lower_str)
    character(len=*), intent(in) :: str
    character(len=len(str)) :: lower_str
    integer :: i
    do i = 1, len(str)
        if (str(i:i) >= 'A' .and. str(i:i) <= 'Z') then
            lower_str(i:i) = char(ichar(str(i:i)) + 32)
        else
            lower_str(i:i) = str(i:i)
        end if
    end do
end function to_lower

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
    end if

    write(unidad, '(A)') '    <h2>Tokens Identificados</h2>'
    write(unidad, '(A)') '    <table>'
    write(unidad, '(A)') '        <tr><th>No</th><th>Lexema</th><th>Tipo</th><th>Fila</th><th>Columna</th></tr>'
    do i = 1, num_tokens
        write(unidad, '(A,I0,A,A,A,A,A,I0,A,I0,A)') '        <tr><td>', i, '</td><td>', &
            trim(tokens(i)%lexema), '</td><td>', trim(tokens(i)%tipo), '</td><td>', &
            tokens(i)%fila, '</td><td>', tokens(i)%columna, '</td></tr>'
    end do
    write(unidad, '(A)') '    </table>'

    write(unidad, '(A)') '</body>'
    write(unidad, '(A)') '</html>'

    close(unidad)
end subroutine generar_html

end module analizador_lexico

program main
    use analizador_lexico
    implicit none
    
    character(len=100000) :: entrada
    type(token) :: tokens(MAX_TOKENS)
    type(error) :: errores(MAX_ERRORES)
    integer :: num_tokens, num_errores, io_status
    integer :: i  ! Added declaration for the loop variable
    
    ! Leer la entrada completa del archivo
    entrada = ""
    do
        read(*, '(A)', iostat=io_status) entrada(len_trim(entrada)+1:)
        if (io_status /= 0) exit
    end do
    
    if (len_trim(entrada) == 0) then
        print *, "Error: No se proporcionó entrada."
        stop
    end if
    
    ! Realizar el análisis léxico
    call analizar(entrada, tokens, num_tokens, errores, num_errores)
    
    ! Generar el archivo HTML con los resultados
    call generar_html(tokens, num_tokens, errores, num_errores)
    
    ! Imprimir un resumen en la consola
    print *, "Análisis completado."
    print *, "Tokens identificados:", num_tokens
    print *, "Errores encontrados:", num_errores
    print *, "Resultados guardados en 'resultado_analisis.html'."
    
    ! Imprimir errores en la consola para una revisión rápida
    if (num_errores > 0) then
        print *, "Resumen de errores:"
        do i = 1, num_errores
            print '(A,I0,A,A,A,A,A,I0,A,I0)', "Error ", i, ": ", &
                trim(errores(i)%descripcion), " - '", trim(errores(i)%caracter_o_palabra), &
                "' en Fila ", errores(i)%fila, ", Columna ", errores(i)%columna
        end do
    end if
    
end program main