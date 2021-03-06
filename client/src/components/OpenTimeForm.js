import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import OpenTimeInputs from "./OpenTimeInput";
import { AddButton } from "./Buttons";
import { Card, CardContent, Typography } from "@material-ui/core";

function OpenTimeForm(props) {
  const { value, onChange } = props;
  const [hours, setHours] = useState(props.value);
  const [errorMessages, setErrorMessages] = useState([]);

  useEffect(() => {
    setHours(value);
  }, [value]);

  const validate = (hours) => {
    let messages = [];
    for (let i = 0; i < hours.length; i++) {
      const row = hours[i];
      if (!row.weekOfMonth && row.weekOfMonth !== 0) {
        messages.push(`Row ${i + 1}: Week of Month is required`);
      }
      if (!row.dayOfWeek) {
        messages.push(`Row ${i + 1}: Day of Week is required`);
      }
      if (!row.open) {
        messages.push(`Row ${i + 1}: Opening  Time is required`);
      }
      if (!row.close) {
        messages.push(`Row ${i + 1}: Closing Time is required`);
      }
    }
    return messages;
  };

  const handleChange = (newHours) => {
    setHours(newHours);
    setErrorMessages(validate(newHours));
    onChange({ target: { value: newHours, name: "hours" } });
  };

  const addHours = () => {
    let newHours = [
      ...hours,
      { weekOfMonth: 0, dayOfWeek: "", open: "", close: "" },
    ];
    handleChange(newHours);
  };

  const removeHours = (e, index) => {
    let newHours = hours.filter((val, i) => i !== index);
    handleChange(newHours);
  };

  const copyHours = (e, index) => {
    const newRange = { ...hours[index] };
    let newHours = [...hours, newRange];
    handleChange(newHours);
  };

  const stateChange = (e, rowIndex) => {
    let newHours = [...hours];
    const name = e.target.name;
    const value = e.target.value;
    if (name === "open" || name === "close") {
      newHours[rowIndex][name] = handleTime(value);
    } else {
      newHours[rowIndex][name] = value;
    }
    handleChange(newHours);
  };

  const handleTime = (number) => {
    //formats time input into HH:MM:SS format
    let output = "";
    number.replace(
      /^\D*(\d{0,2})\D*(\d{0,2})\D*(\d{0,2})/,
      (match, hh, mm, ss) => {
        if (hh.length) {
          output += hh;
          if (mm.length) {
            output += `:${mm}`;
            if (ss.length) {
              output += `:${ss}`;
            }
          }
        }
      }
    );
    return output;
  };

  const inputsMap = hours.map((val, rowIndex) => {
    return (
      <div key={rowIndex}>
        <OpenTimeInputs
          values={val}
          onChange={(e) => stateChange(e, rowIndex)}
          removeInput={(e) => removeHours(e, rowIndex)}
          copyInput={(e) => copyHours(e, rowIndex)}
        />
      </div>
    );
  });

  return (
    <Card style={{ border: "1px solid lightgray", borderRadius: "4px" }}>
      <CardContent>
        <Typography>Hours</Typography>
        <div>{inputsMap}</div>
        {errorMessages.length > 0
          ? errorMessages.map((msg) => (
              <div key={msg} style={{ color: "red" }}>
                {msg}
              </div>
            ))
          : null}
        <AddButton onClick={addHours} label={"Add Hours"} />
      </CardContent>
    </Card>
  );
}

OpenTimeForm.propTypes = {
  value: PropTypes.array,
  onChange: PropTypes.func,
};

export default OpenTimeForm;
