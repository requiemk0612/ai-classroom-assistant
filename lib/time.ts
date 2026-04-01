import dayjs from "dayjs";

export function formatTime(value: string): string {
  return dayjs(value).format("HH:mm");
}
