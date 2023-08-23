import React from "react"
import "gantt-task-react/dist/index.css"
import { ViewMode } from "gantt-task-react"
type ViewSwitcherProps = {
  isChecked: boolean,
  onViewListChange: (isChecked: boolean) => void,
  onViewModeChange: (viewMode: ViewMode) => void
}
export const ViewSwitcher: React.FC<ViewSwitcherProps> = ({
  onViewModeChange,
  onViewListChange,
  isChecked,
}) => {
  return (
    <div className="ViewContainer">
    <span className="Switch" />
      <label className="Switch_Toggle">
      Show Task List
        <input
          type="checkbox"
          defaultChecked={isChecked}
          onClick={() => onViewListChange(!isChecked)}
        />
        <span className="Slider" />
      </label>
      <button
        className="Button"
        onClick={() => onViewModeChange(ViewMode.Hour)}
      >
        Hour
      </button>
      <button className="Button" onClick={() => onViewModeChange(ViewMode.Day)}>
        Day
      </button>
      <button
        className="Button"
        onClick={() => onViewModeChange(ViewMode.Week)}
      >
        Week
      </button>
      <button
        className="Button"
        onClick={() => onViewModeChange(ViewMode.Month)}
      >
        Month
      </button>
    </div>
  )
}