Software_CRUD_v2/
│
├── controllers/
│   └── usuario_controller.py      # Lógica que conecta UI ↔ DAO
│
├── dao/
│   └── usuario_dao.py             # Operaciones CRUD contra la BD
│
├── database/
│   ├── conexion.py                # Conexión a la BD
│   └── universidad.sql            # Script SQL
│
├── models/
│   └── usuario.py                 # Clase/modelo de datos Usuario
│
├── resources/
│   ├── icons/                     # Íconos .png / .svg
│   └── style.qss                  # Hoja de estilos Qt
│
├── ui/
│   ├── usuarios_ui.py             # Generado desde el .ui (pyuic5/pyside6)
│   └── usuarios.ui                # Diseño Qt Designer (solo visual)
│
├── validators/
│   └── usuario_validator.py       # Todas las validaciones
│
├── main.py                        # Punto de entrada de la aplicación
├── README.md                      # Información general del proyecto
└── requirements.txt               # Dependencias del proyecto