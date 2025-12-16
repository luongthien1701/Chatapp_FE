class Ip {
  String ip = "localhost";
  String getIp() {
    return 'http://$ip:8080/api';
  }
}