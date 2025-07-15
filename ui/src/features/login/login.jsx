import * as React from 'react';
import { useMsal, useIsAuthenticated } from "@azure/msal-react";
import { InteractionStatus } from "@azure/msal-browser";

import { loginRequest } from "../../msal/authConfig";

const Login = () => {
  const { instance, inProgress } = useMsal();
  const isAuthenticated = useIsAuthenticated();
  const loginAttempted = React.useRef(false);

  React.useEffect(() => {
    (async () => {
      if (!isAuthenticated && inProgress === InteractionStatus.None && !loginAttempted.current) {
        loginAttempted.current = true;

        await instance.loginRedirect(loginRequest).catch((e) => {
          console.log("LOGIN ERROR:");
          console.log("--------------");
          console.error(e);
          console.log("--------------");

          loginAttempted.current = false; // Reset on failure
        });
      }
    })();
  }, [isAuthenticated, inProgress, instance]);

  return(null)
};

export default Login;
