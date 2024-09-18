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