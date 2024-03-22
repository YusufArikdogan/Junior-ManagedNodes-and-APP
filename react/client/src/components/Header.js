import React from "react";
import cw from "../assets/cw.svg";
import "./style.css";

const Header = () => {
  return (
    <div>
      <div className="text-center">
        <img src={cw} alt="" className="cw" />
        <h6 className="text-center mt-5">
          "This app has been created by Yusuf Arikdogan on behalf of Konzek for the Junior Level Assignment"
        </h6>
        <h1 className="text-center mt-5 header-text">Junior Level Todos</h1>
      </div>
    </div>
  );
};

export default Header;
