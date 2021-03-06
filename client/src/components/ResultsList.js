import React from "react";
import SelectedStakeholderDisplay from "./ResultsSelectedStakeholder";
import PropTypes from "prop-types";
import mapMarker from "./mapMarker";
import { makeStyles } from "@material-ui/core/styles";
import pantryIcon from "../images/pantryIcon.svg";
import mealIcon from "../images/mealIcon.svg";
import splitPantryMealIcon from "../images/splitPantryMealIcon.svg";
import {
  MEAL_PROGRAM_CATEGORY_ID,
  FOOD_PANTRY_CATEGORY_ID,
  VERIFICATION_STATUS,
} from "../constants/stakeholder";

const useStyles = makeStyles((theme) => ({
  stakeholderArrayHolder: {
    width: "100%",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
  },
  stakeholderHolder: {
    width: "80%",
    minHeight: "6em",
    display: "inherit",
    justifyContent: "space-between",
    padding: "1em 0",
    borderBottom: " .2em solid #f1f1f1",
  },
  imgHolder: {
    display: "inherit",
    justifyContent: "center",
    alignItems: "center",
  },
  typeLogo: {
    width: "72px",
  },
  infoHolder: {
    fontSize: "1.1em",
    textAlign: "left",
    width: "60%",
    display: "inherit",
    flexDirection: "column",
    justifyContent: "space-between",
  },
  checkHolder: {
    width: "10%",
    display: "flex",
    flexDirection: "column",
    justifyContent: "space-between",
  },
}));

const ResultsList = ({
  doSelectStakeholder,
  selectedStakeholder,
  stakeholders,
}) => {
  const classes = useStyles();

  return (
    <div className={classes.stakeholderArrayHolder}>
      {stakeholders && selectedStakeholder ? (
        <SelectedStakeholderDisplay
          doSelectStakeholder={doSelectStakeholder}
          selectedStakeholder={selectedStakeholder}
        />
      ) : stakeholders ? (
        stakeholders.map((stakeholder) => (
          <div
            className={classes.stakeholderHolder}
            key={stakeholder.id}
            onClick={() => doSelectStakeholder(stakeholder)}
          >
            <div className={classes.imgHolder}>
              <img
                src={
                  stakeholder.categories[0].id === FOOD_PANTRY_CATEGORY_ID &&
                  stakeholder.categories[1] &&
                  stakeholder.categories[1].id === MEAL_PROGRAM_CATEGORY_ID
                    ? splitPantryMealIcon
                    : stakeholder.categories[0].id === FOOD_PANTRY_CATEGORY_ID
                    ? pantryIcon
                    : mealIcon
                }
                alt={
                  stakeholder.categories[0].id === FOOD_PANTRY_CATEGORY_ID
                    ? "Pantry Icon"
                    : "Meal Icon"
                }
                className={classes.typeLogo}
              />
            </div>
            <div className={classes.infoHolder}>
              <span>{stakeholder.name}</span>
              <span>{stakeholder.address1}</span>
              <div>
                {stakeholder.city} {stakeholder.zip}
              </div>
              <em
                style={{
                  color:
                    stakeholder.categories[0].id === FOOD_PANTRY_CATEGORY_ID
                      ? "#336699"
                      : "#CC3333",
                }}
              >
                {stakeholder.categories[0].name}
              </em>
              {stakeholder.categories[1] ? (
                <em
                  style={{
                    color: "#CC3333",
                  }}
                >
                  {stakeholder.categories[1].name}
                </em>
              ) : null}
            </div>
            <div className={classes.checkHolder}>
              {stakeholder.distance >= 10
                ? stakeholder.distance.toString().substring(0, 3).padEnd(4, "0")
                : stakeholder.distance.toString().substring(0, 3)}{" "}
              mi
              {mapMarker(
                stakeholder.categories[0].id === FOOD_PANTRY_CATEGORY_ID &&
                  stakeholder.categories[1] &&
                  stakeholder.categories[1].id === MEAL_PROGRAM_CATEGORY_ID
                  ? ""
                  : stakeholder.categories[0].id === FOOD_PANTRY_CATEGORY_ID
                  ? "#336699"
                  : "#CC3333",
                stakeholder.verificationStatusId ===
                  VERIFICATION_STATUS.VERIFIED
                  ? true
                  : false
              )}
            </div>
          </div>
        ))
      ) : null}
    </div>
  );
};

ResultsList.propTypes = {
  selectedStakeholder: PropTypes.object,
  stakeholders: PropTypes.arrayOf(PropTypes.object),
};

export default ResultsList;
