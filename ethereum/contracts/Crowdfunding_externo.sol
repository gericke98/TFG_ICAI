pragma solidity  ^0.5.4;


contract Crowdfunding_externo {

    //Inicialización de variables
    enum Estado {
        Financiando,
        Expirado,
        Exitoso
    } //Variable personal creada con tres posibles valores de vuelta

    address public presidente; //Identificación del manager del crowdfunding que coincide con el presidente de la comunidad
    uint public objetivo; // Objetivo de inversión
    uint256 public balance; //Balance actual del crowdfunding
    string public titulo; //Titulo del crowdfunding
    string public descripcion; //Descripción del crowdfunding

    Estado public estado = Estado.Financiando; // Inicialización de variable Estado
    mapping (address => uint) public contribuciones; //Mapping de la lista de inversiones
    address payable public instaladores; //Address de la empresa instaladora
    // Evento que se ejecutará cunado se recibe una inversion
    event InversionRecibida(address inversor, uint inversion, uint total_actual);

    // Evento que se ejecutará cuando el presidente de la comunidad recibe los fondos
    event Presidentepagado(address receptor);

    // Modifier para comprobar estado actual del crowdfunding
    modifier inState(Estado _state) {
        require(estado == _state);
        _;
    }

    // Modifier para comprobar si el que ejecuta la funcion es el presidente de la comunidad
    modifier isCreator() {
        require(msg.sender == presidente);
        _;
    }

    //Función que se ejecura al crear el contrato
    constructor(
      address payable creador,
      string memory titulo2,
      string memory descripcion2,
      uint objetivo2,
      address payable receptor)
      public {
      //Iniccializacion de variables con los inputs introducidos
        presidente = creador;
        titulo = titulo2;
        descripcion = descripcion2;
        objetivo = objetivo2;
        balance = 0;
        instaladores = receptor;
    }

    //Funcion para invertir en el crowdfunding
    function invertir () inState(Estado.Financiando) public payable {
        require(msg.sender != instaladores);
        contribuciones[msg.sender] = contribuciones[msg.sender] + msg.value;
        balance = balance + msg.value;
        emit InversionRecibida(msg.sender, msg.value, balance);
        comprobarCrowdfundingfinalizado();
    }

  //Funcion para comprobar si crowdfunding sigue abierto
    function comprobarCrowdfundingfinalizado() private {
        if (balance >= objetivo) {
            estado = Estado.Exitoso;
            payOut();
        }
    }

  //Funcion para distribuir pagos del crowdfunding
    function payOut() internal inState(Estado.Exitoso) returns (bool) {
        uint256 invertido = balance;
        balance = 0;

        if (instaladores.send(invertido)) {
            emit Presidentepagado(presidente);
            return true;
        } else {
            balance = invertido;
            estado = Estado.Exitoso;
            return false;
        }

    }

    function reembolso() public inState(Estado.Expirado) returns (bool) {
        require(contribuciones[msg.sender] > 0);

        uint reembolsar_cantidad = contribuciones[msg.sender];
        contribuciones[msg.sender] = 0;

        if (!msg.sender.send(reembolsar_cantidad)) {
            contribuciones[msg.sender] = reembolsar_cantidad;
            return false;
        } else {
            balance = balance - reembolsar_cantidad;
        }

        return true;
    }

  //Funcion para obtener informacion del crowdfunding
    function Informacion() public view returns (
        address creador_proyecto,
        string memory titulo_proyecto,
        string memory descripcion_proyecto,
        Estado estado_actual,
        uint256 balance2,
        uint256 objetivo2
    ) {
        creador_proyecto = presidente;
        titulo_proyecto = titulo;
        descripcion_proyecto = descripcion;
        estado_actual = estado;
        balance2 = balance;
        objetivo2 = objetivo;
    }
}
