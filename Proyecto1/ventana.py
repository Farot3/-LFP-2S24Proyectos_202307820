import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox
from PIL import Image, ImageTk

# Variables globales para almacenar las rutas de los archivos
original_file_path = None
current_file_path = None
tree_image = None  # Variable global para almacenar la imagen del canvas


def Cargar_archivo():
    global original_file_path, current_file_path
    file_path = filedialog.askopenfilename(filetypes=[("ORG files", "*.ORG")])
    if file_path:
        with open(file_path, "r") as file:
            content = file.read()
        output_area.delete("1.0", tk.END)
        output_area.insert(tk.END, content)


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

        # Procesar la salida para dividirla en partes
        partes = output.split(",")
        if len(partes) >= 3:
            pais_nombre = partes[0].strip()
            poblacion = partes[1].strip()
            bandera_ruta = partes[2].strip()

            # Actualizar la información en la interfaz
            pais_label.config(text=f"País seleccionado: {pais_nombre}")
            poblacion_label.config(text=f"Población: {poblacion}")

            # Cargar y mostrar la bandera
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
            messagebox.showinfo("Proceso completado", mensaje)

            # Cargar y mostrar la imagen en el canvas
            cargar_imagen_canvas("grafica_paises.png")
        else:
            raise Exception(
                "No se pudo extraer la información del país seleccionado. \nRevise el archivo con errores"
            )

    except Exception as e:
        print(f"Error: {str(e)}")
        messagebox.showerror("Error", f"No se pudo ejecutar el análisis: {str(e)}")
        limpiar_labels()


def limpiar_labels():
    pais_label.config(text="País seleccionado:")
    poblacion_label.config(text="Población:")
    bandera_label.config(image="")
    tree_canvas.delete("all")


def Guardar():
    global original_file_path
    if original_file_path:
        # Guardar en el archivo original
        content = output_area.get("1.0", tk.END)
        with open(original_file_path, "w") as file:
            file.write(content)
        messagebox.showinfo("Guardar", "Archivo guardado exitosamente.")
    else:
        file_path = filedialog.asksaveasfilename(
            defaultextension=".ORG", filetypes=[("ORG files", "*.ORG")]
        )
        if file_path:
            # Asegurarse de que el archivo tenga la extensión .ORG
            if not file_path.endswith(".ORG"):
                file_path += ".ORG"
            original_file_path = file_path
            content = output_area.get("1.0", tk.END)
            with open(file_path, "w") as file:
                file.write(content)
            messagebox.showinfo("Guardar como", "Archivo guardado exitosamente.")


def Guardar_como():
    global original_file_path, current_file_path
    file_path = filedialog.asksaveasfilename(
        defaultextension=".ORG", filetypes=[("ORG files", "*.ORG")]
    )
    if file_path:
        # Asegurarse de que el archivo tenga la extensión .ORG
        if not file_path.endswith(".ORG"):
            file_path += ".ORG"
        current_file_path = file_path
        content = output_area.get("1.0", tk.END)
        with open(file_path, "w") as file:
            file.write(content)
        messagebox.showinfo("Guardar como", "Archivo guardado exitosamente.")


def Salir():
    ventana.quit()


def Datos_estudiantes():
    messagebox.showinfo(
        "Datos", "Ottoniel Fabricio Vásquez Pineda \n202307820 \nLFP, sección B+"
    )


def cargar_imagen_canvas(ruta_imagen):
    global tree_image
    try:
        imagen = Image.open(ruta_imagen)
        imagen = imagen.resize((700, 350), Image.Resampling.LANCZOS)
        tree_image = ImageTk.PhotoImage(imagen)
        tree_canvas.create_image(0, 0, anchor=tk.NW, image=tree_image)
    except Exception as e:
        print(f"Error al cargar la imagen en el canvas: {str(e)}")


# Crear la ventana principal
ventana = tk.Tk()
ventana.title("Interfaz Tkinter con Fortran")
ventana.geometry("1200x600")

# Crear menú
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

# Crear notebook
notebook = tk.Frame(ventana, bg="#262626")
notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

tab_label = tk.Label(
    notebook, text="Analizador de datos", relief=tk.RIDGE, bg="#333333", fg="white"
)
tab_label.pack(side=tk.TOP, anchor=tk.W, pady=5)

# Crear frames principales
left_frame = tk.Frame(
    notebook, width=400, height=500, relief=tk.SUNKEN, bd=1, bg="#1a1a1a"
)
left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5, pady=5)

right_frame = tk.Frame(
    notebook, width=400, height=500, relief=tk.SUNKEN, bd=1, bg="#1a1a1a"
)
right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=5, pady=5)

# Elementos en el frame izquierdo
output_area = tk.Text(left_frame, height=25, width=50, bg="#333333", fg="white")
output_area.pack(pady=10)

tk.Button(
    left_frame,
    text="Analizar",
    command=Enviar_Datos,
    bg="#990000",
    fg="white",
).pack(pady=5)

# Elementos en el frame derecho
label_tipo_grafica = tk.Label(
    right_frame, text="Gráfica", font=("Arial", 12), bg="#1a1a1a", fg="#ff6666"
)
label_tipo_grafica.pack(side=tk.TOP, pady=10)

# Simulación de árbol en el canvas
tree_canvas = tk.Canvas(right_frame, width=700, height=350, bg="#262626")
tree_canvas.pack(pady=10)

# Información del país
info_frame = tk.Frame(right_frame, bg="#1a1a1a")
info_frame.pack(side=tk.BOTTOM, fill=tk.X, pady=10)

# Colocación de las etiquetas a la izquierda
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

# Colocación de la imagen a la derecha
bandera_label = tk.Label(info_frame, bg="#1a1a1a")
bandera_label.pack(side=tk.RIGHT, padx=20)

# Ejecutar la ventana
ventana.mainloop()
