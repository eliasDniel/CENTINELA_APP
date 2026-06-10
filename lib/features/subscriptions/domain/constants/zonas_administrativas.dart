// Zonas administrativas del cantón Milagro y sus barrios
const kZonasAdministrativas = [
  'Milagro',
  'Chobo',
  'Mariscal Sucre',
  'Roberto Astudillo',
];

const kBarriosPorZona = <String, List<String>>{
  'Milagro': [
    'Chirijos',
    'Camilo Andrade',
    'Ernesto Seminario',
    'Coronel Enrique Valdez',
  ],
  'Chobo': [
    'Paraíso de Chobo',
    'Otros recintos',
  ],
  'Mariscal Sucre': [],
  'Roberto Astudillo': [],
};

/// Máximo de barrios adicionales al de registro (RF-0309).
const kMaxBarriosAdicionales = 3;

bool zonaTieneBarrios(String zona) =>
    (kBarriosPorZona[zona] ?? []).isNotEmpty;

List<String> barriosDeZona(String zona) =>
    List.unmodifiable(kBarriosPorZona[zona] ?? []);

/// Todos los barrios de todas las zonas (para visitantes).
List<String> get todosLosBarrios => kBarriosPorZona.values
    .expand((barrios) => barrios)
    .toList(growable: false);
