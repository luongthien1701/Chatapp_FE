class Ip {
  String ip = "192.168.1.13";
  String getIp() {
    return 'http://$ip:8080/api';
  }
}