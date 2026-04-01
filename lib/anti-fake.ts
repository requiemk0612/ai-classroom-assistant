const studentCooldown = new Map<string, number>();

export function canSendFeedback(studentId: string): boolean {
  const now = Date.now();
  const lastTime = studentCooldown.get(studentId) ?? 0;
  if (now - lastTime < 3000) {
    return false;
  }
  studentCooldown.set(studentId, now);
  return true;
}
