package ca.jrvs.devops.SimpleApp;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

  //Getting the value from system env var
  private String spring_profiles_active = System.getenv("spring_profiles_active");

  //Getting the value from the application.properties file
  @Value("${app.version}")
  private String appVersion;

  //Getting the value from the application.properties file
  @Value("${app.greetingMessage}")
  private String greetingMessage;

  @RequestMapping("/")
  public String index() {
    return greetingMessage + "<br> environment=" + spring_profiles_active + "<br>version="
        + appVersion;
  }

}