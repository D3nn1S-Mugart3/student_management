import 'package:flutter/material.dart';
import 'package:student_management/db_student.dart';
import 'package:student_management/models/student.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final DatabaseStudents databaseStudents = DatabaseStudents();
  List<Student> students = [];

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController nacimientoController = TextEditingController();
  final TextEditingController generoController = TextEditingController();
  final TextEditingController gradoController = TextEditingController();
  final TextEditingController nombreTutorController = TextEditingController();
  final TextEditingController promedioCalificacionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final data = await databaseStudents.getEstudiantes();
    setState(() {
      students = data;
    });
  }

  void _showForm([Student? student]) {
    if (student != null) {
      nombreController.text = student.nombre;
      edadController.text = student.edad.toString();
      correoController.text = student.correo;
      telefonoController.text = student.telefono;
      direccionController.text = student.direccion;
      nacimientoController.text = student.nacimiento.toString();
      generoController.text = student.genero;
      gradoController.text = student.grado;
      nombreTutorController.text = student.nombreTutor;
      promedioCalificacionController.text =
          student.promedioCalificacion.toString();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            Text(student == null ? 'Agregar estudiante' : 'Editar estudiante'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(
                controller: nacimientoController,
                decoration:
                    const InputDecoration(labelText: 'Fecha de Nacimiento')),
            TextField(
                controller: generoController,
                decoration: const InputDecoration(labelText: 'Género')),
            TextField(
                controller: edadController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number),
            TextField(
                controller: correoController,
                decoration:
                    const InputDecoration(labelText: 'Correo Electrónico')),
            TextField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono')),
            TextField(
                controller: direccionController,
                decoration: const InputDecoration(labelText: 'Dirección')),
            TextField(
                controller: gradoController,
                decoration: const InputDecoration(labelText: 'Grado')),
            TextField(
                controller: nombreTutorController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del Tutor')),
            TextField(
                controller: promedioCalificacionController,
                decoration: const InputDecoration(labelText: 'Promedio (GPA)'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isNotEmpty &&
                  edadController.text.isNotEmpty) {
                int age = int.parse(edadController.text);
                double gpa = double.parse(promedioCalificacionController.text);
                DateTime dateOfBirth =
                    DateTime.parse(nacimientoController.text);

                if (student == null) {
                  await databaseStudents.insertEstudiante(Student(
                    studentId: DateTime.now().toString(),
                    nombre: nombreController.text,
                    edad: age,
                    correo: correoController.text,
                    telefono: telefonoController.text,
                    direccion: direccionController.text,
                    nacimiento: dateOfBirth,
                    genero: generoController.text,
                    grado: gradoController.text,
                    nombreTutor: nombreTutorController.text,
                    fechaInscripcion: DateTime.now(),
                    promedioCalificacion: gpa,
                  ));
                } else {
                  await databaseStudents.updateEstudiante(Student(
                    id: student.id,
                    studentId: student.studentId,
                    nombre: nombreController.text,
                    edad: age,
                    correo: correoController.text,
                    telefono: telefonoController.text,
                    direccion: direccionController.text,
                    nacimiento: dateOfBirth,
                    genero: generoController.text,
                    grado: gradoController.text,
                    nombreTutor: nombreTutorController.text,
                    fechaInscripcion: student.fechaInscripcion,
                    promedioCalificacion: gpa,
                  ));
                }

                Navigator.of(context).pop();
                _loadStudents();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(int id) async {
    await databaseStudents.deleteEstudiante(id);
    _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de estudiantes')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            title: Text(student.nombre),
            subtitle: Text(student.correo),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showForm(student)),
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteStudent(student.id!)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(), child: const Icon(Icons.add)),
    );
  }
}
