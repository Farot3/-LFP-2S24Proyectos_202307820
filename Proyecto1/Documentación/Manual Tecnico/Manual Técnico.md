UNIVERSIDAD DE SAN CARLOS DE GUATEMALA

FACULTAD DE INGENIERIA

ESTRUCTURA DE DATOS

CATEDRÁTICO: ING. DAVID

============================================================================================
<div align="center" style="background-image: url('logousac.png'); background-size: cover; background-position: center; height: 400px; display: flex; justify-content: center; align-items: center; text-align: center; background-color: rgba(255, 255, 255, 0.3);">
  
  <div>
    <h1 style="color: black; text-decoration: underline; text-decoration-color: black;" >MANUAL DE USUARIO</h1>
  </div>
  
</div>
============================================================================================
<p align="right">
OTTONIEL FABRICIO VÁSQUEZ PINEDA
<br>
CARNÉ: 202307820
<br>
SECCIÓN B+
</p>

<P align="center">GUATEMALA 19 DE SEPTIEMBRE DEL 2024</P>

============================================================================================
<br>
<br>
<br>
<h2 align="center"> Introducción </h2>
En este proyecto lo que se quiere hacer es hacer un analisis de paises y continentes en la cual se quiere hacer una oficina de banco en la cual se seleccionara el país con menos saturación osea con menos competencia de comercio en la cual se pueda hacer un buen negocio, en la cual en este manual se enseñara lo que es el proceso que se llevo para crear este programa y funcione correctamente y se le mostrará todo lo que se hiso ya que se trabajo con 2 lenguajes, en la cual uno sirvio para backend y otro para frontend, el lenguaje que se uso para el backend es Fortran y para el frontend se uso Phyton.
<br>
<br>
<h2 align="center"> Objetivos del sistema </h2>

### GENERAL
- Proveer una guía detallada y estructurada para el usuario y desarrollador, facilitando el entendimiento, uso y mantenimiento del proyecto, asegurando que todas las funcionalidades y procedimientos del código sean claros y accesibles.


### Específicos
1. Explicar de manera detallada la implementación y uso de las diferentes funciones y subrutinas del código, incluyendo la carga de del archivo .ORG, el analisis que hace el programa.
2. Instruir al usuario final sobre cómo interactuar con el proyecto a través de una interfaz, guiándolo en la ejecución de tareas comunes como la carga del archivo .ORG, el analizador del archivo para seleccionar país.
<br>
<br>

<h1 align="center"> Frontend </h1>
En el frontend se uso el lenguaje de phyton en la cual solo se hiso la interfaz y también algunos labels en la cual se iba a enseñar el texto que se analizara, el pais seleccionado con su población, la gráfica y diferentes opciones que son abrir el archivo .ORG, guardar y guardar como, con otras opciones que son acerca de y también la opción de salir en la enseñaré como es el código de cada función y cuales fueron las caracteristicas que se le puso a la interfaz.
<br>
<br>
No se describira lo que hace cada función de lo que hace el frontend ya que con los titulos ya se pueden dar una ídea de que hace cada cosa.

### importaciones
~~~python
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox
from PIL import Image, ImageTk
~~~
<br>

<h1 align="center"> Funciones en python para mostrar datos </h1>

### Variables para almacenar archivos
~~~python
original_file_path = None
current_file_path = None
tree_image = None 
~~~

### Función cargar archivo
~~~python
def Cargar_archivo():
    global original_file_path, current_file_path
    file_path = filedialog.askopenfilename(filetypes=[("ORG files", "*.ORG")])
    if file_path:
        with open(file_path, "r") as file:
            content = file.read()
        output_area.delete("1.0", tk.END)
        output_area.insert(tk.END, content)
~~~

### Función enviar datos
~~~python
def Enviar_Datos():
    content = output_area.get("1.0", tk.END).strip()
    if not content:
        messagebox.showerror("Error", "No hay contenido para analizar.")
        return

    try:
        resultado = subprocess.run(
            ["./analisis.exe"],
            input=content,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
        )

        if resultado.returncode != 0:
            raise Exception(f"Error en Fortran: {resultado.stderr}")

        output = resultado.stdout.strip()
        print("Depuración: Salida del programa Fortran:")
        print(output)

        partes = output.split(",")
        if len(partes) >= 3:
            pais_nombre = partes[0].strip()
            poblacion = partes[1].strip()
            bandera_ruta = partes[2].strip()
            pais_label.config(text=f"País seleccionado: {pais_nombre}")
            poblacion_label.config(text=f"Población: {poblacion}")

            try:
                imagen = Image.open(bandera_ruta)
                imagen = imagen.resize((150, 100), Image.Resampling.LANCZOS)
                foto = ImageTk.PhotoImage(imagen)
                bandera_label.config(image=foto)
                bandera_label.image = foto
            except Exception as e:
                print(f"Error al cargar la imagen, no se encontro: {str(e)}")
                bandera_label.config(image="")

            mensaje = f"Análisis completado.\nPaís seleccionado: {pais_nombre}\nPoblación: {poblacion}"
            output_area.insert(tk.END, "\n" + mensaje + "\n")
            messagebox.showinfo("Proceso completado", mensaje)

            cargar_imagen_canvas("grafica_paises.png")
        else:
            raise Exception(
                "No se pudo extraer la información del país seleccionado. \nRevise el archivo con errores"
            )

    except Exception as e:
        print(f"Error: {str(e)}")
        messagebox.showerror("Error", f"No se pudo ejecutar el análisis: {str(e)}")
        limpiar_labels()
~~~

### Función limpiar labels
~~~python
def limpiar_labels():
    pais_label.config(text="País seleccionado:")
    poblacion_label.config(text="Población:")
    bandera_label.config(image="")
    tree_canvas.delete("all")
~~~

### Función Guardar
~~~python
def Guardar():
    global original_file_path
    if original_file_path:
        content = output_area.get("1.0", tk.END)
        with open(original_file_path, "w") as file:
            file.write(content)
        messagebox.showinfo("Guardar", "Archivo guardado exitosamente.")
    else:
        file_path = filedialog.asksaveasfilename(
            defaultextension=".ORG", filetypes=[("ORG files", "*.ORG")]
        )
        if file_path:
            if not file_path.endswith(".ORG"):
                file_path += ".ORG"
            original_file_path = file_path
            content = output_area.get("1.0", tk.END)
            with open(file_path, "w") as file:
                file.write(content)
            messagebox.showinfo("Guardar como", "Archivo guardado exitosamente.")
~~~

### Función guardar como
~~~python
def Guardar_como():
    global original_file_path, current_file_path
    file_path = filedialog.asksaveasfilename(
        defaultextension=".ORG", filetypes=[("ORG files", "*.ORG")]
    )
    if file_path:
        if not file_path.endswith(".ORG"):
            file_path += ".ORG"
        current_file_path = file_path
        content = output_area.get("1.0", tk.END)
        with open(file_path, "w") as file:
            file.write(content)
        messagebox.showinfo("Guardar como", "Archivo guardado exitosamente.")
~~~

### Función salir
~~~python
def Salir():
    ventana.quit()
~~~

### Función de cargar imagen gráfica
~~~python
def cargar_imagen_canvas(ruta_imagen):
    global tree_image
    try:
        imagen = Image.open(ruta_imagen)
        imagen = imagen.resize((700, 350), Image.Resampling.LANCZOS)
        tree_image = ImageTk.PhotoImage(imagen)
        tree_canvas.create_image(0, 0, anchor=tk.NW, image=tree_image)
    except Exception as e:
        print(f"Error al cargar la imagen en el canvas: {str(e)}")
~~~
<br>
<br>

<h1 align="center"> Creación de la interfaz y mostrarla </h1>

~~~python
ventana = tk.Tk()
ventana.title("Interfaz Tkinter con Fortran")
ventana.geometry("1200x600")

menu_bar = tk.Menu(
    ventana,
    bg="#333333",
    fg="white",
    activebackground="#444444",
    activeforeground="white",
)
ventana.config(menu=menu_bar)

menu_opciones = tk.Menu(menu_bar, tearoff=0, bg="#333333", fg="white")
menu_bar.add_cascade(label="Menú", menu=menu_opciones)
menu_bar.add_cascade(label="Acerca de", command=Datos_estudiantes)
menu_bar.add_cascade(label="Salir", command=Salir)

menu_opciones.add_command(label="Abrir", command=Cargar_archivo)
menu_opciones.add_separator()
menu_opciones.add_command(label="Guardar", command=Guardar)
menu_opciones.add_command(label="Guardar como", command=Guardar_como)

notebook = tk.Frame(ventana, bg="#262626")
notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

tab_label = tk.Label(
    notebook, text="Analizador de datos", relief=tk.RIDGE, bg="#333333", fg="white"
)
tab_label.pack(side=tk.TOP, anchor=tk.W, pady=5)

left_frame = tk.Frame(
    notebook, width=400, height=500, relief=tk.SUNKEN, bd=1, bg="#1a1a1a"
)
left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5, pady=5)

right_frame = tk.Frame(
    notebook, width=400, height=500, relief=tk.SUNKEN, bd=1, bg="#1a1a1a"
)
right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=5, pady=5)

output_area = tk.Text(left_frame, height=25, width=50, bg="#333333", fg="white")
output_area.pack(pady=10)

tk.Button(
    left_frame,
    text="Analizar",
    command=Enviar_Datos,
    bg="#990000",
    fg="white",
).pack(pady=5)

label_tipo_grafica = tk.Label(
    right_frame, text="Gráfica", font=("Arial", 12), bg="#1a1a1a", fg="#ff6666"
)
label_tipo_grafica.pack(side=tk.TOP, pady=10)

tree_canvas = tk.Canvas(right_frame, width=700, height=350, bg="#262626")
tree_canvas.pack(pady=10)

info_frame = tk.Frame(right_frame, bg="#1a1a1a")
info_frame.pack(side=tk.BOTTOM, fill=tk.X, pady=10)

label_info_frame = tk.Frame(info_frame, bg="#1a1a1a")
label_info_frame.pack(side=tk.LEFT, fill=tk.X)

pais_label = tk.Label(
    label_info_frame, text="País seleccionado:", bg="#1a1a1a", fg="white"
)
pais_label.pack(anchor="w")

poblacion_label = tk.Label(
    label_info_frame, text="Población:", bg="#1a1a1a", fg="white"
)
poblacion_label.pack(anchor="w")

bandera_label = tk.Label(info_frame, bg="#1a1a1a")
bandera_label.pack(side=tk.RIGHT, padx=20)

ventana.mainloop()
~~~


<h1 align="center"> Backend </h1>
En esta parte se trabajo con Fortran en la cual se explicaran algunas funciones pero no todas, más que todos las importantes y un poco de texto para que se pueda entender que hace cada función, ya que para hacer este analizador se hicieron varias funciones.

## Modulo de Analizador lexico

### Tipos de definidos para guardar datos
~~~fortran
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
    
    type pais
        character(len=100) :: nombre
        character(len=100) :: continente
        integer :: poblacion
        real :: saturacion
        character(len=200) :: bandera
    end type pais
    
    type continente
        character(len=100) :: nombre
        real :: saturacion_promedio
        integer :: num_paises
    end type continente

    type grafica
        character(len=100) :: nombre
        integer :: num_continentes
    end type grafica
~~~


### Variables, parametros, caracteres
~~~fortran
integer, parameter :: MAX_TOKENS = 1000
    integer, parameter :: MAX_ERRORES = 100
    integer, parameter :: MAX_PAISES = 100
    integer, parameter :: MAX_CONTINENTES = 10
    
    character(len=20), dimension(11), parameter :: palabras_reservadas = [character(len=20) :: &
        "grafica", "nombre", "continente", "pais", "poblacion", "saturacion", "bandera", ":", "{", "}", ";"]
    
    type(grafica) :: grafica_actual
    type(pais), dimension(MAX_PAISES) :: paises
    type(continente), dimension(MAX_CONTINENTES) :: continentes
    integer :: num_paises = 0
    integer :: num_continentes = 0
~~~

## Subrutinas

### Subrutina analizar
En esta subrutina como dice su nombre, se analiza el archivo más que todo para captar letras y palabras, no solo eso sino que también va guardando los datos que necesita para procesar lo demás y dar resultados.
~~~fortran
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
    logical :: esperando_numero

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
    esperando_numero = .false.

    indice = 1
    do while (indice <= len_trim(entrada))
        c = entrada(indice:indice)
        procesar_actual = .true.
        
        select case (estado)
        case (0)
            inicio_lexema = fila
            inicio_col = columna
            if (c == '{' .or. c == '}' .or. c == ':' .or. c == ';') then
                call agregar_token(tokens, num_tokens, c, get_token_type(c), fila, columna)
                if (c == '{') then
                    dentro_bloque = .true.
                    nivel_anidamiento = nivel_anidamiento + 1
                else if (c == '}') then
                    nivel_anidamiento = nivel_anidamiento - 1
                    if (nivel_anidamiento == 0) dentro_bloque = .false.
                end if
            else if (c == '"') then
                estado = 1
                lexema_actual = c
            else if (es_letra_minuscula(c)) then
                estado = 2
                lexema_actual = c
            else if (es_digito(c)) then
                if (.not. esperando_numero) then
                    call agregar_error(errores, num_errores, "Número fuera de lugar permitido", c, fila, columna)
                else
                    estado = 3
                    lexema_actual = c
                end if
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
            
        case (1)
            lexema_actual = trim(lexema_actual) // c
            if (c == '"' .and. lexema_actual(len_trim(lexema_actual)-1:len_trim(lexema_actual)-1) /= '\/') then
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
            
        case (2) reservadas
            if (es_letra_minuscula(c) .or. es_digito(c) .or. c == '_') then
                lexema_actual = trim(lexema_actual) // c
            else
                if (es_palabra_reservada(lexema_actual)) then
                    call agregar_token(tokens, num_tokens, lexema_actual, "RESERVADA", inicio_lexema, inicio_col)
                    if (lexema_actual == "poblacion" .or. lexema_actual == "saturacion") then
                        esperando_numero = .true.
                    else
                        esperando_numero = .false.
                    end if
                else
                    if (.not. dentro_bloque) then
                        call agregar_error(errores, num_errores, "Palabra fuera de bloque permitido", lexema_actual, fila, columna)
                    else
                        if (.not. es_palabra_permitida_en_bloque(lexema_actual, nivel_anidamiento)) then
                            call agregar_error(errores, num_errores, "Palabra no permitida dentro del bloque", lexema_actual, fila, columna)
                        else
                            call agregar_token(tokens, num_tokens, lexema_actual, "IDENTIFICADOR", inicio_lexema, inicio_col)
                        end if
                    end if
                end if
                estado = 0
                procesar_actual = .false.
            end if
            
        case (3)
            if (es_digito(c)) then
                lexema_actual = trim(lexema_actual) // c
            else if (c == '%') then
                lexema_actual = trim(lexema_actual) // c
                call agregar_token(tokens, num_tokens, lexema_actual, "PORCENTAJE", inicio_lexema, inicio_col)
                estado = 0
                lexema_actual = ""
                esperando_numero = .false.
            else
                call agregar_token(tokens, num_tokens, lexema_actual, "NUMERO", inicio_lexema, inicio_col)
                estado = 0
                procesar_actual = .false.
                esperando_numero = .false.
            end if
        end select
        
        if (procesar_actual) then
            indice = indice + 1
            columna = columna + 1
        end if
    end do
    
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
~~~

### Subrutina agregar token
Esta subrutina se encarga más que todo de agregar los tokens que existen para mandarlos al archivo html para enseñar que tokens hay.
~~~fortran
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
~~~

### Subrutina agregar error
En esta subrutina se van agregando los errores que se vayan encontrando en el archivo y los va exportando a un acrhivo html para que se pueda apreciar cuales son los errores.
~~~fortran
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
~~~

### Subrutina crear el archivo html de tokens y errores
Lo que hace esta subrutina como su nombre dice crea un html con tokens y los errores, solo que la diferencia, esque si hay un error, solo hace el de errores y si no hay ni un error, hace el de tokens
~~~fortran
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
~~~

### Subrutina para calcular la saturación de continentes
Así como dice su nombre, calcula la saturación de los continentes por medio de una operación matemática, con la cual ayuda a sacar el promedio de todos los paises crenado la saturación del continente.
~~~fortran
subroutine calcular_saturacion_continentes()
    integer :: i, j
    real :: suma_saturacion
    
    do i = 1, num_continentes
        suma_saturacion = 0.0
        continentes(i)%num_paises = 0
        do j = 1, num_paises
            if (trim(paises(j)%continente) == trim(continentes(i)%nombre)) then
                suma_saturacion = suma_saturacion + paises(j)%saturacion
                continentes(i)%num_paises = continentes(i)%num_paises + 1
            end if
        end do
        if (continentes(i)%num_paises > 0) then
            continentes(i)%saturacion_promedio = suma_saturacion / continentes(i)%num_paises
        else
            continentes(i)%saturacion_promedio = 0.0
        end if
    end do
end subroutine calcular_saturacion_continentes
~~~

### Subrutina del país con menor saturación
Lo que hace esta subrutina esque busca entre todos los paises al país que tenga menor saturación de todos los paises, no solo hace eso, sino que también esta subrutina le manda a python los datos del país que se selecciono con menor saturación.
~~~fortran
subroutine seleccionar_pais_menor_saturacion()
    integer :: i, indice_pais_seleccionado
    real :: menor_saturacion
    
    if (num_paises == 0) then
        print *, "Error: No hay datos suficientes para seleccionar un país."
        return
    end if
    
    menor_saturacion = paises(1)%saturacion
    indice_pais_seleccionado = 1
    
    do i = 2, num_paises
        if (paises(i)%saturacion < menor_saturacion) then
            menor_saturacion = paises(i)%saturacion
            indice_pais_seleccionado = i
        end if
    end do
    
    print *, trim(paises(indice_pais_seleccionado)%nombre) // "," // trim(adjustl(itoa(paises(indice_pais_seleccionado)%poblacion))) // "," // trim(paises(indice_pais_seleccionado)%bandera)
end subroutine seleccionar_pais_menor_saturacion
~~~

### subrutina para procesar datos
Lo que hace esta subrutina más que todo es procesar todos los datos del archivo, para saber que hacer con estos datos y así enviarlos a sus respectivos lugares y también se podría decir.
~~~fortran
subroutine procesar_datos(tokens, num_tokens)
    type(token), intent(in) :: tokens(MAX_TOKENS)
    integer, intent(in) :: num_tokens
    integer :: i, estado, nivel_anidamiento
    character(len=100) :: nombre_pais, nombre_continente
    integer :: poblacion
    real :: saturacion
    character(len=200) :: bandera
    
    estado = 0
    nivel_anidamiento = 0
    grafica_actual%num_continentes = 0
    grafica_actual%nombre = ""
    
    do i = 1, num_tokens
        select case (estado)
        case (0)
            if (tokens(i)%lexema == "grafica") then
                estado = 1
            end if
        case (1)
            if (tokens(i)%lexema == "{") then
                nivel_anidamiento = nivel_anidamiento + 1
                estado = 2
            end if
        case (2)
            if (tokens(i)%lexema == "nombre") then
                estado = 3
            else if (tokens(i)%lexema == "continente") then
                grafica_actual%num_continentes = grafica_actual%num_continentes + 1
                estado = 10
            else if (tokens(i)%lexema == "}") then
                nivel_anidamiento = nivel_anidamiento - 1
                if (nivel_anidamiento == 0) then
                    estado = 0
                end if
            end if
        case (3)
            if (tokens(i)%lexema == ":") then
                estado = 4
            end if
        case (4)
            if (tokens(i)%tipo == "CADENA") then
                grafica_actual%nombre = tokens(i)%lexema(2:len_trim(tokens(i)%lexema)-1)
                estado = 2
            end if
        case (10)
            if (tokens(i)%lexema == "{") then
                nivel_anidamiento = nivel_anidamiento + 1
                estado = 11
            end if
        case (11)
            if (tokens(i)%lexema == "nombre") then
                estado = 12
            else if (tokens(i)%lexema == "pais") then
                estado = 20
            else if (tokens(i)%lexema == "}") then
                nivel_anidamiento = nivel_anidamiento - 1
                if (nivel_anidamiento == 1) then
                    estado = 2
                end if
            end if
        case (12)
            if (tokens(i)%lexema == ":") then
                estado = 13
            end if
        case (13)
            if (tokens(i)%tipo == "CADENA") then
                nombre_continente = tokens(i)%lexema(2:len_trim(tokens(i)%lexema)-1)
                call actualizar_continente(nombre_continente, 0.0)
                estado = 11
            end if
        case (20)
            if (tokens(i)%lexema == "{") then
                nivel_anidamiento = nivel_anidamiento + 1
                estado = 21
                nombre_pais = ""
                poblacion = 0
                saturacion = 0.0
                bandera = ""
            end if
        case (21)
            if (tokens(i)%lexema == "nombre") then
                estado = 22
            else if (tokens(i)%lexema == "poblacion") then
                estado = 24
            else if (tokens(i)%lexema == "saturacion") then
                estado = 26
            else if (tokens(i)%lexema == "bandera") then
                estado = 28
            else if (tokens(i)%lexema == "}") then
                nivel_anidamiento = nivel_anidamiento - 1
                call agregar_pais(nombre_pais, nombre_continente, poblacion, saturacion, bandera)
                if (nivel_anidamiento == 2) then
                    estado = 11
                end if
            end if
        case (22)
            if (tokens(i)%lexema == ":") then
                estado = 23
            end if
        case (23)
            if (tokens(i)%tipo == "CADENA") then
                nombre_pais = tokens(i)%lexema(2:len_trim(tokens(i)%lexema)-1)
                estado = 21
            end if
        case (24)
            if (tokens(i)%lexema == ":") then
                estado = 25
            end if
        case (25)
            if (tokens(i)%tipo == "NUMERO") then
                read(tokens(i)%lexema, *) poblacion
                estado = 21
            end if
        case (26)
            if (tokens(i)%lexema == ":") then
                estado = 27
            end if
        case (27)
            if (tokens(i)%tipo == "PORCENTAJE") then
                read(tokens(i)%lexema(1:len_trim(tokens(i)%lexema)-1), *) saturacion
                estado = 21
            end if
        case (28)
            if (tokens(i)%lexema == ":") then
                estado = 29
            end if
        case (29)
            if (tokens(i)%tipo == "CADENA") then
                bandera = tokens(i)%lexema(2:len_trim(tokens(i)%lexema)-1)
                estado = 21
            end if
        end select
    end do
    
    call calcular_saturacion_continentes()
end subroutine procesar_datos
~~~

### Subrutina para agregar pais
Lo que hace este país esque al llamar a esta subrutina, le agrega a cada país sus datos, osea su población, el continente de donde es, su nomrbe, su saturación y su bandera y lo va guardando como si fuera una lista.
~~~fortran
subroutine agregar_pais(nombre, continente, poblacion, saturacion, bandera)
    character(len=*), intent(in) :: nombre, continente, bandera
    integer, intent(in) :: poblacion
    real, intent(in) :: saturacion
    
    if (num_paises < MAX_PAISES) then
        num_paises = num_paises + 1
        paises(num_paises)%nombre = nombre
        paises(num_paises)%continente = continente
        paises(num_paises)%poblacion = poblacion
        paises(num_paises)%saturacion = saturacion
        paises(num_paises)%bandera = bandera
        
        call actualizar_continente(continente, saturacion)
    else
        print *, "Error: Número máximo de países alcanzado."
    end if
end subroutine agregar_pais
~~~

### Subrutina para agregar continente
Esta subrutina es similar a la anterior, pero en lugar de agregar un país, agrega contienente
~~~fortran
subroutine actualizar_continente(nombre_continente, saturacion)
    character(len=*), intent(in) :: nombre_continente
    real, intent(in) :: saturacion
    integer :: i, indice_continente
    
    indice_continente = 0
    do i = 1, num_continentes
        if (continentes(i)%nombre == nombre_continente) then
            indice_continente = i
            exit
        end if
    end do
    
    if (indice_continente == 0) then
        if (num_continentes < MAX_CONTINENTES) then
            num_continentes = num_continentes + 1
            continentes(num_continentes)%nombre = nombre_continente
            continentes(num_continentes)%saturacion_promedio = saturacion
            continentes(num_continentes)%num_paises = 1
        else
            print *, "Error: Número máximo de continentes alcanzado."
        end if
    else
        continentes(indice_continente)%saturacion_promedio = &
            (continentes(indice_continente)%saturacion_promedio * continentes(indice_continente)%num_paises + saturacion) / &
            (continentes(indice_continente)%num_paises + 1)
        continentes(indice_continente)%num_paises = continentes(indice_continente)%num_paises + 1
    end if
end subroutine actualizar_continente
~~~

### Subrutina gráfica
Lo que hace esta subrutina es hacer la grafica de los continentes con su propios paises mostrando su saturación exportandolo como archivo imagen y también como archivo .dot.
~~~fortran
subroutine graphiv_Process(grafica_actual, continentes, num_continentes, paises, num_paises)
    type(grafica), intent(in) :: grafica_actual
    type(continente), intent(in) :: continentes(MAX_CONTINENTES)
    integer, intent(in) :: num_continentes
    type(pais), intent(in) :: paises(MAX_PAISES)
    integer, intent(in) :: num_paises
    
    character(len=10000) :: dot_code
    character(len=20) :: color
    character(len=20) :: saturacion_str
    character(len=100) :: nombre_grafica
    integer :: i, j

    if (len_trim(grafica_actual%nombre) == 0) then
        nombre_grafica = "Grafica_Sin_Nombre"
        print *, "Utilizando nombre predeterminado para la gráfica:", trim(nombre_grafica)
    else
        nombre_grafica = grafica_actual%nombre
    end if
    
    if (num_continentes <= 0 .or. num_paises <= 0) then
        print *, "Error: Invalid data for graph generation"
        return
    end if
    
    dot_code = "digraph G {" // new_line('A') // &
               'rankdir=TB;' // new_line('A') // &
               'node [shape=box, style=filled, fontname="Arial"];' // new_line('A')
    
    dot_code = trim(dot_code) // '"' // trim(nombre_grafica) // '" [shape=diamond];' // new_line('A')
    
    do i = 1, num_continentes
        if (len_trim(continentes(i)%nombre) == 0) then
            print *, "Advertencia: Nombre de continente vacío, saltando..."
            cycle 
        end if
        
        color = obtener_color(continentes(i)%saturacion_promedio)
        write(saturacion_str, '(F5.1)') continentes(i)%saturacion_promedio

        dot_code = trim(dot_code) // '"' // trim(continentes(i)%nombre) // '" [label="' // &
                   trim(continentes(i)%nombre) // '\n' // trim(adjustl(saturacion_str)) // '%", fillcolor=' // &
                   trim(color) // '];' // new_line('A')
        
        dot_code = trim(dot_code) // '"' // trim(nombre_grafica) // '" -> "' // &
                   trim(continentes(i)%nombre) // '";' // new_line('A')
        
        do j = 1, num_paises
            if (len_trim(paises(j)%nombre) == 0 .or. len_trim(paises(j)%continente) == 0) then
                print *, "Advertencia: Nombre de país o continente vacío, saltando..."
                cycle
            end if
            
            if (trim(paises(j)%continente) == trim(continentes(i)%nombre)) then
                color = obtener_color(paises(j)%saturacion)
                write(saturacion_str, '(F5.1)') paises(j)%saturacion
                
                dot_code = trim(dot_code) // '"' // trim(paises(j)%nombre) // '" [label="' // &
                           trim(paises(j)%nombre) // '\n' // trim(adjustl(saturacion_str)) // '%", fillcolor=' // &
                           trim(color) // '];' // new_line('A')
                
                dot_code = trim(dot_code) // '"' // trim(continentes(i)%nombre) // '" -> "' // &
                           trim(paises(j)%nombre) // '";' // new_line('A')
            end if
        end do
    end do
    
    dot_code = trim(dot_code) // '}' // new_line('A')
    
    open(unit=11, file="grafica_paises.dot", status='replace')
    write(11, '(A)') trim(dot_code)
    close(11)
    
    call system("dot -Tpng grafica_paises.dot -o grafica_paises.png")
end subroutine graphiv_Process
~~~


## Funciones

### Función de palabras permitidas en bloques
Esta función solo permite ciertas palabras en bloques, como continente, nombre, pais como ejemplos ya que no permite otro tipo de palabras para analizar este archivo.
~~~fortran
function es_palabra_permitida_en_bloque(palabra, nivel_anidamiento) result(res)
    character(len=*), intent(in) :: palabra
    integer, intent(in) :: nivel_anidamiento
    logical :: res

    res = .false.
    select case (nivel_anidamiento)
    case (1)
        if (palabra == "nombre" .or. palabra == "continente") then
            res = .true.
        end if
    case (2)
        if (palabra == "nombre" .or. palabra == "pais") then
            res = .true.
        end if
    case (3)
        if (palabra == "nombre" .or. palabra == "poblacion" .or. palabra == "saturacion" .or. palabra == "bandera") then
            res = .true.
        end if
    end select
end function es_palabra_permitida_en_bloque
~~~

### Función para obtener el tipo de token
Esta función recibe tokens también pero otro tipo de tokens, que en este caso sería los simbolos que se ve adelante.
~~~fortran
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
~~~

### Función letra minuscula
Esta función lo que hace, esque hace que el analizador solo acepte letras en minusculas.
~~~fortran
function es_letra_minuscula(c) result(res)
    character, intent(in) :: c
    logical :: res
    res = (c >= 'a' .and. c <= 'z')
end function es_letra_minuscula
~~~

### Función para mayusculas
Esta función lo que hace, esque hace que el analizador agregue como error las letras en mayusculas
~~~fortran
function es_letra_mayuscula(c) result(res)
    character, intent(in) :: c
    logical :: res
    res = (c >= 'A' .and. c <= 'Z')
end function es_letra_mayuscula
~~~

### Función para numeros
Esta función lo que hace, esque hace que el analizador tome en cuenta los numeros y que los agregue como tokens también los numeros
~~~fortran
function es_digito(c) result(res)
    character, intent(in) :: c
    logical :: res
    res = (c >= '0' .and. c <= '9')
end function es_digito
~~~

### Función para palabras reservadas
~~~fortran
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
~~~

### Función itoa
Lo que hace esta función es limpiar todos los caracteres que estén en blanco de una oración o palabra para que solo esté la palabra sin espacios en blanco.
~~~fortran
function itoa(i) result(str)
    implicit none
    integer, intent(in) :: i
    character(len=12) :: str
    write(str, '(I0)') i
end function itoa
~~~

### Función obtención de color
Esta función lo que haces que pueda obtener el color dependiendo de que tanta saturación tiene cada país y también continente y eso lo va mostrando en la gráfica.
~~~fortran
function obtener_color(saturacion) result(color)
    real, intent(in) :: saturacion
    character(len=20) :: color
    
    if (saturacion <= 15.0) then
        color = "white"
    else if (saturacion <= 30.0) then
        color = "blue"
    else if (saturacion <= 45.0) then
        color = "green"
    else if (saturacion <= 60.0) then
        color = "yellow"
    else if (saturacion <= 75.0) then
        color = "orange"
    else
        color = "red"
    end if
end function obtener_color
~~~

## Por último tenemos el main
Aquí como así dice el titulo es el maín, donde se lleva a cabo el proceso de todo y como se llama a cada función y también donde se obtienen primnero los datos desde python
~~~fortran
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
    
    if (num_errores > 0) then
        call generar_html(tokens, num_tokens, errores, num_errores)
    else
        call procesar_datos(tokens, num_tokens)
        call calcular_saturacion_continentes()
        call graphiv_Process(grafica_actual, continentes, num_continentes, paises, num_paises)
        call seleccionar_pais_menor_saturacion()
        call generar_html(tokens, num_tokens, errores, num_errores)
    end if
    
end program main
~~~