pragma solidity ^0.4.25;

contract VotacionFactory {
    address[] public deployedvotations;

    function createVotation(uint vecinos) public {
        address newVotation = new Votation(vecinos, msg.sender);
        deployedvotations.push(newVotation);
    }

    function getDeployedVotations() public view returns (address[]) {
        return deployedvotations;
    }
}

contract Votation {
    //Declaracion de variables
    struct Voto {
      bool ha_votado; //Variable para representar si ha votado o no. En caso de haber votado devuelve false
      uint voto_favor; //Variable para votar a favor
      uint voto_contra; //Variable para votar a favor
    }

    struct Proposicion {
      string nombre; //Nombre de la propuesta
      uint votos_favor; //Numero de votos a favor
      uint votos_contra; //Numero de votos en contra
      bool exitoso; //Si votacion exitosa devuelve true
    }

    address public presidente; //Address del presidente de la comunidad

    mapping(address => Voto) public votantes; //Mapping que asigna una identidad digital a cada estrctura de votantes

    Proposicion public proposiciones;

    uint vecinos;

    modifier esPresidente {
      require(msg.sender == presidente);
      _;
    }

    modifier tieneVoto(address votante) {
      require(votantes[votante].ha_votado);
      _;
    }

    modifier total {
        require(proposiciones.votos_favor+proposiciones.votos_contra==vecinos);
        _;
    }

    function Votation(uint vecinos2, address creator) public {
        presidente = creator;
        vecinos = vecinos2;
    }

    //Funcion para dar derecho a voto a un vecino
      function dar_derecho_voto(address votante) public esPresidente {
        votantes[votante].ha_votado=true;
      }


    //Funcion para votar a favor
      function votar_a_favor() public tieneVoto(address(msg.sender)) {
        votantes[msg.sender].voto_favor = 1;
        votantes[msg.sender].ha_votado=false;
        proposiciones.votos_favor = proposiciones.votos_favor + 1;
      }

    //Funcion para votar en contra
      function votar_en_contra() public tieneVoto(address(msg.sender)) {
        votantes[msg.sender].voto_contra = 1;
        votantes[msg.sender].ha_votado=false;
        proposiciones.votos_contra = proposiciones.votos_contra + 1;
      }

    //Funcion para ver el numero de votos_favor
      function numero_votos_favor() public view returns(uint, uint){
        return(proposiciones.votos_favor, proposiciones.votos_favor+proposiciones.votos_contra);

      }

    //Funcion para ver el numero de votos_favor
      function numero_votos_contra() public view returns(uint,uint){
        return (proposiciones.votos_contra, proposiciones.votos_favor+proposiciones.votos_contra);
      }

    //Funcion para cerrar votacion. Es requerido que todos los vecinos hayan votado para cerrar votacion
      function cerrar_votacion() public esPresidente total returns(uint, uint) {
        if(((proposiciones.votos_favor*3)/vecinos) >= 1 ){
            proposiciones.exitoso=true;
        }
        return (proposiciones.votos_favor,proposiciones.votos_contra);
      }

    }
