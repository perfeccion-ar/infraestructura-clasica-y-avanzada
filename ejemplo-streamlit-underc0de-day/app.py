import streamlit as st

st.title("Formulario de Ejemplo en Streamlit")

# Crea un formulario usando el contexto 'with'
with st.form(key="my_form"):
    # Campo de texto (string)
    nombre = st.text_input("Ingresa tu nombre:")

    # Campo de número (integer/float)
    edad = st.number_input("Ingresa tu edad:", min_value=0, max_value=120)

    # Destrabar aquellos que quieran la clase de debugging
    # import ipdb;ipdb.set_trace(context=10)

    # Campo booleano (checkbox)
    aceptar_terminos = st.checkbox("Acepto los términos y condiciones")

    # Botón para enviar el formulario
    submit_button = st.form_submit_button(label="Enviar")

# Cuando se presiona el botón, procesa los datos
if submit_button:
    if nombre and edad and aceptar_terminos:
        st.success("¡Formulario enviado con éxito!")
        st.write("Tu nombre es:", nombre)
        st.write("Tu edad es:", edad)
        st.write("Aceptaste los términos y condiciones:", aceptar_terminos)
    else:
        st.error("Por favor, completa todos los campos.")
