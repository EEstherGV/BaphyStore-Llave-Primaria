create schema inicio;

create table inicio.rol(
    name varchar(50) NOT NULL,
    primary key (name)
);

create table inicio.usuario(
    login varchar(50) NOT NULL,
    password varchar(60) NOT NULL,
    email varchar(254) NOT NULL,
    activated int4 NOT NULL,
    lang_key varchar(6) NOT NULL,
    image_url varchar(256) NULL,
    activation_key varchar(20) NULL,
    reset_key varchar(20) NULL,
    reset_date timestamp NULL,
    primary key (login),
    unique (email)
);

create table inicio.usuario_authority(
    name_rol varchar(50),
    login varchar(50),
    primary key (name_rol, login),
    CONSTRAINT fk_ro_au FOREIGN KEY (name_rol) REFERENCES inicio.rol (name),
    CONSTRAINT fk_us_au FOREIGN KEY (login) REFERENCES inicio.usuario (login)
);
create table inicio.tipo_documento(
    sigla varchar(10) NOT NULL,
    nombre_documento varchar(100) NOT NULL,
    estado varchar(40) NOT NULL,
    primary key (sigla),
    unique (nombre_documento)
);
create table inicio.cliente(
    numero_documento varchar(50) NOT NULL,
    primer_nombre    varchar(50) NOT NULL,
    segundo_nombre   varchar(50) NULL,
    primer_apellido  varchar(50) NOT NULL,
    segundo_apellido varchar(50) NULL,
    sigla            varchar(10) NOT NULL,
    login            varchar(50) NOt NULL,
    unique (login),
    primary key (numero_documento, sigla),
    CONSTRAINT fk_tipo_documento FOREIGN KEY (sigla) REFERENCES inicio.tipo_documento (sigla),
    CONSTRAINT fk_usuario FOREIGN KEY (login) REFERENCES inicio.usuario (login)
);

create schema logs;

create table logs.log_errores(
    id int4 NOT NULL,
    nivel varchar(400) NOT NULL,
    log_name varchar(400) NOT NULL,
    mensaje varchar(400) NOT NULL,
    fecha date NOT NULL,
    numero_documento varchar(50) NOT NULL,
    sigla varchar(10) NOT NULL,
    primary key (id),
    foreign key (sigla,numero_documento) references inicio.cliente (sigla, numero_documento)
);

create table logs.log_auditoria(
    id int4 NOT NULL,
    nivel varchar(400) NOT NULL,
    log_name varchar(400) NOT NULL,
    mensaje varchar(400) NOT NULL,
    fecha date NOT NULL,
    numero_documento varchar(50) NOT NULL,
    sigla varchar(10) NOT NULL,
    primary key (id),
    foreign key (sigla,numero_documento) references inicio.cliente (sigla, numero_documento)
);

create schema ficha;

create table ficha.estado_formacion(
  nombre_estado varchar(40) NOT NULL,
  estado varchar(40) NOT NULL,
  primary key (nombre_estado)
);

create table ficha.estado_ficha(
    nombre_estado varchar(20) NOT NULL,
    estado int2 NOT NULL,
    primary key (nombre_estado)
);

create table ficha.jornada(
    sigla_jornada varchar(20) NOT NULL,
    nombre_jornada varchar(40) NOT NULL,
    descripcion varchar(100) NOT NULL,
    imagen_url varchar(1000) NULL,
    estado varchar(40) NOT NULL,
    primary key (sigla_jornada),
    unique (nombre_jornada)
);

create table ficha.aprendiz(
    numero_documento varchar(50) NOT NULL,
    sigla varchar(10) NOT NULL,
    numero_ficha varchar(100)NOT NULL,
    nombre_estado varchar(40) NOT NULL,
    primary key (numero_documento, sigla, numero_ficha),
    FOREIGN KEY (numero_documento, sigla) REFERENCES inicio.cliente (numero_documento, sigla),
    CONSTRAINT fk_esta_apre FOREIGN KEY (nombre_estado) REFERENCES ficha.estado_formacion (nombre_estado)
);
create table ficha.ficha(
    numero_ficha varchar(100) NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    ruta varchar(40) NOT NULL,
    codigo varchar(50) NOT NULL,
    version varchar(40) NOT NULL,
    nombre_estado varchar(20) NOT NULL,
    sigla_jornada varchar(20) NOT NULL,
    primary key (numero_ficha),
    constraint fk_exfi_fich foreign key (nombre_estado) references ficha.estado_ficha (nombre_estado),
    constraint fk_jorn_trim foreign key (sigla_jornada) references ficha.jornada (sigla_jornada)
);

alter table ficha.aprendiz add constraint fk_fich_apre foreign key (numero_ficha) references ficha.ficha (numero_ficha);

create table ficha.trimestre(
    nombre_trimestre int4 NOT NULL,
    nivel varchar(40) NOT NULL,
    sigla_jornada varchar(20) NOT NULl,
    estado varchar(40) NOT NUll,
    primary key (nombre_trimestre, nivel, sigla_jornada),
    FOREIGN KEY (sigla_jornada) REFERENCES ficha.jornada (sigla_jornada)
);

create table ficha.ficha_has_trimestre(
    numero_ficha varchar(100) NOT NULL,
    sigla_jornada varchar(20) NOT NULL,
    nivel varchar(40) NOT NULL,
    nombre_trimestre  int4,
    primary key (numero_ficha, sigla_jornada, nivel, nombre_trimestre),
    FOREIGN KEY (numero_ficha) REFERENCES ficha.ficha (numero_ficha),
    FOREIGN KEY (sigla_jornada, nivel, nombre_trimestre) REFERENCES ficha.trimestre (sigla_jornada, nivel, nombre_trimestre)
);

create table ficha.ficha_planeacion(
    numero_ficha varchar(100) ,
    codigo_planeacio varchar(40) NOT NULL,
    estado varchar(40) NOT NULL,
    primary key (numero_ficha, codigo_planeacio),
    FOREIGN KEY (numero_ficha) REFERENCES ficha.ficha (numero_ficha)
);

create table ficha.resultados_vistos(
    codigo_resultado varchar(40) NOT NULL,
    codigo_competencia varchar(50) NOT NULL,
    codigo_programa varchar(50) NOT NULL,
    version_programa varchar(40) NOT NULL,
    numero_ficha varchar(100) NOT NULL,
    sigla_jornada varchar(20) NOT NULL,
    nivel varchar(40) NOT NULL,
    nombre_trimestre int4 NOT NULL,
    codigo_planeacion varchar(40) NOT NULL,
    primary key (codigo_resultado, codigo_competencia, codigo_programa, version_programa, numero_ficha, sigla_jornada, nivel,
                nombre_trimestre, codigo_planeacion),
    CONSTRAINT fk_fitr_revi FOREIGN KEY (numero_ficha, sigla_jornada, nivel, nombre_trimestre) REFERENCES ficha.ficha_has_trimestre (numero_ficha, sigla_jornada, nivel, nombre_trimestre)
);


create schema programado;

create table programado.planeacion(
    codigo varchar(40) NOT NULL,
    estado varchar(40) NOT NULL,
    fecha date NOT NULL,
    primary key (codigo)
);

create table programado.nivel_formacion(
    nivel varchar(40) NOT NULL,
    estado varchar(40) NOT NULL,
    primary key (nivel)
);
alter table ficha.trimestre add constraint fk_nifo_tri foreign key (nivel) references programado.nivel_formacion (nivel);
alter table ficha.ficha_planeacion add constraint  fk foreign key (codigo_planeacio) references  programado.planeacion (codigo);
alter table ficha.resultados_vistos add constraint  fk_revi_plan foreign key (codigo_planeacion) references programado.planeacion (codigo);

create table programado.programa(
    codigo varchar(50) NOT NULL,
    version varchar(40) NOT NULL,
    nombre varchar(500) NOT NULL,
    sigla varchar(40) NOT NULL,
    estado varchar(40) NOT NULL,
    nivel varchar(40) NOT NULL,
    primary key (codigo, version),
    CONSTRAINT fk_nifo_prog FOREIGN KEY (nivel) REFERENCES programado.nivel_formacion (nivel)
);

alter table ficha.ficha add constraint fk_prog_fich foreign key (codigo, version) references programado.programa (codigo, version);

create table programado.competencia(
    codigo_competencia varchar(50) NOT NULL,
    denominacion varchar(1000) NOT NULL,
    codigo_programa varchar(50) NOT NULL,
    version_programa varchar(40) NOT NULL,
    primary key (codigo_competencia, codigo_programa, version_programa),
    CONSTRAINT fk_prog_comp FOREIGN KEY (codigo_programa, version_programa) REFERENCES programado.programa (codigo, version)
);

create table programado.resultado_aprendiz(
    codigo_resultado varchar(40) NOT NULL,
    denominacion varchar(1000) NOT NULL,
    codigo_competencia varchar(50) NOT NULL,
    codigo_programa varchar(50) NOT NULL,
    version_programa varchar(40) NOT NULL,
    primary key (codigo_resultado, codigo_competencia, codigo_programa, version_programa),
    CONSTRAINT fk_comp_reap FOREIGN KEY (codigo_competencia, codigo_programa, version_programa) REFERENCES programado.competencia (codigo_competencia, codigo_programa, version_programa)
);

alter table ficha.resultados_vistos add constraint fk_reap_revi foreign key (codigo_resultado, codigo_competencia, codigo_programa, version_programa) references programado.resultado_aprendiz (codigo_resultado, codigo_competencia, codigo_programa, version_programa);

create table programado.planeacion_trimestre(
    codigo_resultado varchar(40) NOT NULL,
    codigo_competencia varchar(50) NOT NULL,
    codigo_Programa varchar(50) NOT NULL,
    version_programa varchar(40) NOT NUll,
    sigla_jornada varchar(20) NOT NULL,
    nivel varchar(40) NOT NULL,
    nombre_trimestre int4 NOT NULL,
    codigo_planeacion varchar(40) NOT NULL,
    PRIMARY key (codigo_resultado, codigo_competencia, codigo_Programa, version_programa, sigla_jornada, nivel,
                nombre_trimestre, codigo_planeacion),
    FOREIGN KEY (codigo_planeacion) REFERENCES programado.planeacion (codigo),
    FOREIGN KEY (codigo_resultado, codigo_competencia, codigo_Programa, version_programa) REFERENCES programado.resultado_aprendiz (codigo_resultado, codigo_competencia, codigo_programa, version_programa),
    CONSTRAINT fk_trim_pltr FOREIGN KEY (sigla_jornada, nivel, nombre_trimestre) REFERENCES ficha.trimestre (sigla_jornada, nivel, nombre_trimestre)
);

create table programado.actividad_planeacion(
    codigo_resultado varchar(40) NOT NULL,
    codigo_competencia varchar(50) NOT NULL,
    codigo_programa varchar(50) NOT NULL,
    version_programa varchar(40) NOT NULL,
    sigla_jornada varchar(20) NOT NULL,
    nivel varchar(40) NOT NULL,
    nombre_trimestre int4 NOT NULL,
    nombre_fase varchar(40) NOT NULL,
    codigo_proyecto varchar(40) NOT NULL,
    numero_actividad int4 NOT NULL,
    codigo_planeacion varchar(40),
    primary key (codigo_resultado, codigo_competencia, codigo_programa, version_programa, sigla_jornada, nivel, nombre_trimestre, nombre_fase, codigo_proyecto, numero_actividad, codigo_planeacion),
    CONSTRAINT fk_pltr_acpl FOREIGN KEY (codigo_resultado, codigo_competencia, codigo_programa, version_programa, sigla_jornada, nivel, nombre_trimestre, codigo_planeacion) REFERENCES programado.planeacion_trimestre(codigo_resultado, codigo_competencia, codigo_Programa, version_programa, sigla_jornada, nivel, nombre_trimestre, codigo_planeacion)
);

CREATE SCHEMA proyectos;

CREATE TABLE proyectos.proyecto(
codigo VARCHAR(40) NOT NULL,
nombre VARCHAR (500) NOT NULL,
estado VARCHAR (40) NOT NULL,
codigo_programa VARCHAR (50) NOT NULL,
version VARCHAR (40) NOT NULL,
PRIMARY KEY (codigo),
CONSTRAINT fk_pyoyectos_pro FOREIGN KEY (codigo_programa, version) REFERENCES programado.programa (codigo, version)
);

CREATE TABLE proyectos.fase(
nombre VARCHAR (40) NOT NULL,
estado VARCHAR(40) NOT NULL,
codigo_proyecto VARCHAR(40) NOT NULL,
PRIMARY KEY (nombre, codigo_proyecto),
CONSTRAINT fk_proy_fase FOREIGN KEY (codigo_proyecto) REFERENCES proyectos.proyecto (codigo)
);

CREATE TABLE proyectos.actividad_proyecto(
    numero_actividad int4 NOT NULL,
    descripcion_actividad VARCHAR(400) NOT NULL,
    estado VARCHAR(40) NOT NULL,
    nombre_fase VARCHAR(40) NOT NULL,
    codigo_proyecto VARCHAR(40) NOT NULL,
    PRIMARY KEY (numero_actividad, nombre_fase, codigo_proyecto),
    CONSTRAINT fk_fase_acti FOREIGN KEY (nombre_fase, codigo_proyecto) REFERENCES proyectos.fase (nombre, codigo_proyecto)
);

alter table programado.actividad_planeacion add constraint fk_acti_acpl foreign key (numero_actividad, nombre_fase, codigo_proyecto) references proyectos.actividad_proyecto (numero_actividad, nombre_fase, codigo_proyecto);

CREATE SCHEMA sede;

CREATE TABLE sede.tipo_ambiente(
    tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    estado VARCHAR(40) NOT NULL,
    primary key (tipo)
);

CREATE TABLE sede.sede(
    nombre_sede VARCHAR(50) NOT NULL,
    direccion VARCHAR(400) NOT NULL,
    estado VARCHAR(40) NOT NULL,
    primary key (nombre_sede)
);

CREATE TABLE sede.ambiente(
    numero_ambiente VARCHAR(50) NOT NULL,
    nombre_sede VARCHAR(50) NOT NULL,
    descripcion VARCHAR(1000) NOT NULL,
    estado VARCHAR(40) NOT NULL,
    limitacion VARCHAR(40) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    PRIMARY KEY (numero_ambiente, nombre_sede),
    CONSTRAINT fk_tiam_ambi FOREIGN KEY (tipo) REFERENCES sede.tipo_ambiente (tipo),
    CONSTRAINT fl_sede_ambi FOREIGN KEY (nombre_sede) REFERENCES sede.sede (nombre_sede)
);

CREATE TABLE sede.limitacion_ambiente(
    numero_ambiente    VARCHAR(50) NOT NULL,
    nombre_sede        VARCHAR(50) NOT NULL,
    codigo_resultado   VARCHAR(40) NOT NULL,
    codigo_competencia VARCHAR(50) NOT NULL,
    codigo_programa    VARCHAR(50) NOT NULL,
    version_programa   VARCHAR(40),
    PRIMARY KEY (numero_ambiente, nombre_sede, codigo_resultado, codigo_competencia, codigo_programa, version_programa),
    CONSTRAINT fk_ambi_liam FOREIGN KEY (numero_ambiente, nombre_sede) REFERENCES sede.ambiente (numero_ambiente, nombre_sede),
    CONSTRAINT fk_reap_liam FOREIGN KEY (codigo_resultado, codigo_competencia, codigo_programa, version_programa) REFERENCES programado.resultado_aprendiz (codigo_resultado, codigo_competencia, codigo_programa, version_programa)
);

create schema sustentacion;

create table sustentacion.grupo_proyecto(
  numero_grupo int4 NOT NULL,
  nombre_proyecto varchar(300) NOT NULL,
  estado varchar(40) NOT NULL,
  numero_ficha varchar(100) NOT NULL,
  primary key (numero_grupo, numero_ficha),
  constraint fk_fich_grpr FOREIGN KEY (numero_ficha) REFERENCES ficha.ficha (numero_ficha)
);

create table sustentacion.lista_chequeo(
  lista varchar(50) NOT NULL,
  estado int4 NOT NULL,
  codigo varchar(50) NOT NULL,
  version varchar(40) NOT NULL,
  primary key (lista),
  CONSTRAINT fk_prog_lich FOREIGN KEY (codigo, version) REFERENCES programado.programa (codigo, version)
);

create table sustentacion.valoracion(
  tipo_valoracion varchar(50) NOT NULL,
  estado varchar(40) NOT NULL,
  primary key (tipo_valoracion)
);

create table sustentacion.observacion_general(
    numero int4 NOT NULL,
    observacion varchar(500) NOT NULL,
    jurado varchar(500) NOT NULL,
    fecha timestamp NOT NULL,
    numero_documento varchar(50) NULL,
    sigla varchar(10) NULL,
    numero_grupo int4 NOT NULL,
    numero_ficha varchar(100) NOT NULL,
    primary key (numero, numero_grupo, numero_ficha),
    constraint fk_clie_obge FOREIGN KEY (numero_documento, sigla) REFERENCES inicio.cliente (numero_documento, sigla),
    CONSTRAINT fk_grpr_obge FOREIGN KEY (numero_grupo, numero_ficha) REFERENCES sustentacion.grupo_proyecto (numero_grupo, numero_ficha)
);

create table sustentacion.integrantes_grupo(
    numero_documento varchar(50) NOT NULL,
    sigla varchar(10) NOT NULL,
    numero_ficha varchar(100) NOT NULL,
    numero_grupo int4 NOT NULL,
    numero_ficha2 varchar(100) NOT NULL,
    primary KEY (numero_documento, sigla, numero_ficha, numero_grupo, numero_ficha2),
    CONSTRAINT fk_grpr_ingr FOREIGN KEY (numero_grupo, numero_ficha) REFERENCES sustentacion.grupo_proyecto (numero_grupo, numero_ficha),
    CONSTRAINT fk_apre_ingr FOREIGN KEY (numero_documento, sigla, numero_ficha2) REFERENCES ficha.aprendiz (numero_documento, sigla, numero_ficha)
);

create table sustentacion.lista_ficha(
  numero_ficha varchar(100) NOT NULL,
  lista varchar(50) NOT NULL,
  primary key (numero_ficha),
  unique (lista),
  FOREIGN KEY (lista) REFERENCES sustentacion.lista_chequeo (lista),
  CONSTRAINT fk_fich_lifi FOREIGN KEY (numero_ficha) REFERENCES ficha.ficha (numero_ficha)
);

create table sustentacion.item_lista(
    lista varchar(50) NOT NULL,
    numero_item int4 NOT NULL,
    pregunta varchar(100) NOT NULL,
    id_resultado_aprendizaje int4 NOT NULL,
    codigo_resultado varchar(40) NOT NULL,
    codigo_competencia varchar(50) NOT NULL,
    codigo_programa varchar(50) NOT NULL,
    version_programa varchar(40) NOT NULL,
    primary key (lista, numero_item),
    foreign key (lista) references sustentacion.lista_chequeo (lista),
    constraint fk_reap_itli foreign key (codigo_resultado, codigo_competencia, codigo_programa, version_programa) references programado.resultado_aprendiz (codigo_resultado, codigo_competencia, codigo_programa, version_programa)
);

create table sustentacion.respuesta_grupo(
    fecha timestamp NOT NULL,
    tipo_valoracion varchar(50) NULL,
    numero_grupo int4 NOT NULL,
    numero_ficha varchar(100) NOT NULL,
    lista varchar(50) NOT NULL,
    numero_itemp int4 NOT NULL,
    primary key (numero_grupo, numero_ficha, lista, numero_itemp),
    constraint fk_valo_regr foreign key (tipo_valoracion) references sustentacion.valoracion (tipo_valoracion),
    foreign key (numero_grupo, numero_ficha) references sustentacion.grupo_proyecto (numero_grupo, numero_ficha),
    constraint fk_itli_regr foreign key (lista, numero_itemp) references sustentacion.item_lista (lista, numero_item)
);

create table sustentacion.observacion_respuesta(
    numero_observacion int4 NOT NULL,
    observacion varchar(400) NOT NULL,
    jurados varchar(400) NOT NULL,
    fechas timestamp NOT NULL,
    numero_documento varchar(50) NOT NULL,
    sigla varchar(10) NOT NULL,
    numero_grupo int4 NOT NULL,
    numero_ficha varchar(100) NOT NULL,
    lista varchar(50) NOT NULL,
    numero_item int4 NOT NULL,
    primary key (numero_observacion, numero_grupo, numero_ficha, lista, numero_item),
    foreign key (numero_documento, sigla) references inicio.cliente (numero_documento, sigla),
    constraint fk_regr_obre foreign key (numero_grupo, numero_ficha, lista, numero_item) references sustentacion.respuesta_grupo (numero_grupo, numero_ficha, lista, numero_itemp)
);

CREATE SCHEMA instructor;

CREATE TABLE instructor.area(
	nombre_area VARCHAR(40) NOT NULL,
	estado VARCHAR(40) NOT NULL,
	url_logo VARCHAR(1000) NULL,
	primary key (nombre_area)
);

CREATE TABLE instructor.instructor(
    estado VARCHAR(40) NOT NULL,
	numero_documento VARCHAR(50) NOT NULL,
	sigla VARCHAR(10) NOT NULL,
	PRIMARY KEY (numero_documento, sigla),
    CONSTRAINT fk_cli_inst FOREIGN KEY (numero_documento, sigla) REFERENCES inicio.cliente (numero_documento, sigla)
);

CREATE TABLE instructor.year(
    number_year int4 NOT NULL,
	estado VARCHAR(40) NOT NULL,
	primary key (number_year)
);

CREATE TABLE instructor.vinculacion(
    tipo_vinculacion VARCHAR(40) NOT NULL,
	horas int4 NOT NULL,
	estado VARCHAR(40) NOT NULL,
	primary key (tipo_vinculacion)
);

CREATE TABLE instructor.jornada_instructor(
	nombre_jornada VARCHAR(80) NOT NULL,
	descripcion VARCHAR(200) NOT NULL,
	estado VARCHAR(40) NOT NULL,
	primary key (nombre_jornada)
);

CREATE TABLE instructor.area_instructor(
    numero_documento VARCHAR(50) NOT NULL,
	sigla VARCHAR(10) NOT NULL,
	nombre_area VARCHAR(40) NOT NULL,
	estado VARCHAR(40) NOT NULL,
	primary key (numero_documento, sigla, nombre_area),
	CONSTRAINT fk_intr_arin FOREIGN KEY (numero_documento, sigla) references instructor.instructor (numero_documento, sigla),
	CONSTRAINT fk_area_arin FOREIGN KEY (nombre_area) references instructor.area (nombre_area)
);

CREATE TABLE instructor.vinculacion_instructor(
    fecha_inicio DATE NOT NULL,
	fecha_fin DATE NOT NULL,
	numero_documento VARCHAR(50) NOT NULL,
	sigla VARCHAR(10) NOT NULL,
	number_year INT NOT NULL,
	tipo_vinculacion VARCHAR(40) NOT NULL,
    PRIMARY KEY (fecha_inicio, numero_documento, sigla, number_year, tipo_vinculacion),
    constraint fk_inst_viis FOREIGN KEY (numero_documento, sigla) REFERENCES instructor.instructor (numero_documento, sigla),
    constraint fk_year_viis FOREIGN KEY (number_year) REFERENCES instructor.year (number_year),
	constraint fk_vinc_viis FOREIGN KEY (tipo_vinculacion) REFERENCES instructor.vinculacion (tipo_vinculacion)
);

CREATE TABLE instructor.dia_jornada(
    hora_inicio int4 NOT NULL,
	hora_fin int4 NOT NULL,
	nombre_jornada VARCHAR(80) NOT NULL,
	nombre_dia VARCHAR(40) NOT NULL,
	PRIMARY KEY (hora_inicio, hora_fin, nombre_jornada, nombre_dia),
	FOREIGN KEY (nombre_jornada) REFERENCES instructor.jornada_instructor (nombre_jornada)
);

CREATE TABLE instructor.disponibilidad_competencias(
    codigo_competencia VARCHAR(50) NOT NULL,
	codigo_programa VARCHAR(50) NOT NULL,
	version_programa VARCHAR(40) NOT NULL,
	numero_documento VARCHAR(50) NOT NULL,
	sigla VARCHAR(10) NOT NULL,
	number_year int4 NOT NULL,
	tipo_vinculacion VARCHAR(40) NOT NULL,
	fecha_inicio DATE NOT NULL,
	PRIMARY KEY (codigo_competencia, codigo_programa, version_programa, numero_documento, sigla, number_year, tipo_vinculacion, fecha_inicio),
    constraint fk_comp_dico FOREIGN KEY (codigo_competencia, codigo_programa, version_programa) REFERENCES programado.competencia (codigo_competencia, codigo_programa, version_programa),
    constraint fk_viis_dico FOREIGN KEY (fecha_inicio, numero_documento, sigla, number_year, tipo_vinculacion) REFERENCES instructor.vinculacion_instructor (fecha_inicio, numero_documento, sigla, number_year, tipo_vinculacion)
);

CREATE TABLE instructor.disponibilidad_horaria(
	numero_documento VARCHAR(50) NOT NULL,
	sigla VARCHAR(10) NOT NULL,
	number_year int4 NOT NULL,
	tipo_vinculacion VARCHAR(40) NOT NULL,
	fecha_inicio DATE NOT NULL,
	nombre_jornada VARCHAR(80) NOT NULL,
	PRIMARY KEY (numero_documento, sigla, number_year, tipo_vinculacion, fecha_inicio, nombre_jornada),
    constraint fk_viin_diho FOREIGN KEY (fecha_inicio, numero_documento, sigla, number_year, tipo_vinculacion) REFERENCES instructor.vinculacion_instructor (fecha_inicio, numero_documento, sigla, number_year, tipo_vinculacion),
    constraint fk_join_diho FOREIGN KEY (nombre_jornada) REFERENCES instructor.jornada_instructor (nombre_jornada)
);

CREATE SCHEMA horarios;

CREATE TABLE horarios.dia (
	nombre_dia VARCHAR(40) NOT NULL,
	estado VARCHAR(40) NOT NULL,
	primary key (nombre_dia)
);
alter table instructor.dia_jornada add constraint fk_dia_dijo foreign key (nombre_dia) references horarios.dia (nombre_dia);

CREATE TABLE horarios.modalidad(
	nombre_modalidad VARCHAR(40) NOT NULL,
	color VARCHAR(50) NOT NULL,
	estado	VARCHAR(40) NOT NULL,
	primary key (nombre_modalidad)
);

CREATE TABLE horarios.trimestre_vigente(
	trimestre_programado int4 NOT NULL,
	fecha_inicio DATE NOT NULL,
	fecha_fin DATE NOT NULL,
	estado VARCHAR(40) NOT NULL,
	number_year int4 NOT NULL,
	PRIMARY KEY (trimestre_programado, number_year),
	FOREIGN KEY (number_year) REFERENCES instructor.year (number_year)
);

CREATE TABLE horarios.version_horario(
	numero_version VARCHAR(40) NOT NULL,
	estado 	VARCHAR (40) NOT NULL,
	number_year int4 NOT NULL,
	trimestre_programado int4 NOT NULL,
	PRIMARY KEY (numero_version, number_year, trimestre_programado),
	CONSTRAINT fk_trvi_veho FOREIGN KEY (number_year, trimestre_programado) REFERENCES horarios.trimestre_vigente (number_year, trimestre_programado)
);

CREATE TABLE horarios.horario(
    hora_inicio          TIME         NOT NULL,
    hora_fin             TIME         NOT NULL,
    numero_documento     VARCHAR(50)  NOT NULL,
    sigla                VARCHAR(10)  NOT NULL,
    numero_ambiente      VARCHAR(50)  NOT NULL,
    nombre_sede          VARCHAR(50)  NOT NULL,
    numero_ficha         VARCHAR(100) NOT NULL,
    sigla_jornada        VARCHAR(20)  NOT NULL,
    nivel                VARCHAR(40)  NOT NULL,
    nombre_trismestre    int4         NOT NULL,
    nombre_dia           VARCHAR(40)  NOT NULL,
    nombre_modalidad     VARCHAR(40)  NOT NULL,
    numero_version       VARCHAR(40)  NOT NULL,
    number_year          int4         NOT NULL,
    trimestre_programado int4         NOT NULL,
    PRIMARY KEY (hora_inicio, hora_fin, numero_documento, sigla, numero_ambiente, nombre_sede, numero_ficha,
                 sigla_jornada, nivel, nombre_trismestre, nombre_dia, nombre_modalidad, numero_version, number_year, trimestre_programado),
    CONSTRAINT fk_veho_hora FOREIGN KEY (numero_version, number_year, trimestre_programado) REFERENCES horarios.version_horario (numero_version, number_year, trimestre_programado),
    CONSTRAINT fk_inst_hora FOREIGN KEY (numero_documento, sigla) REFERENCES instructor.instructor (numero_documento, sigla),
    CONSTRAINT fk_moda_hora FOREIGN KEY (nombre_modalidad) REFERENCES horarios.modalidad (nombre_modalidad),
    CONSTRAINT fk_ambi_hora FOREIGN KEY (numero_ambiente, nombre_sede) REFERENCES sede.ambiente (numero_ambiente, nombre_sede),
    CONSTRAINT fk_fitr_hora FOREIGN KEY (numero_ficha, sigla_jornada, nivel, nombre_trismestre) REFERENCES ficha.ficha_has_trimestre (numero_ficha, sigla_jornada, nivel, nombre_trimestre),
    CONSTRAINT fk_dia_hora FOREIGN KEY (nombre_dia) REFERENCES horarios.dia (nombre_dia)
);
