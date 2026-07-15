const TRIGGER_SIGNUP_URL = "https://us-central1-devops-learning-p1-teja.cloudfunctions.net/trigger-signup";
const GET_JOB_STATUS_URL = "https://us-central1-devops-learning-p1-teja.cloudfunctions.net/get-job-status";

const signupForm = document.getElementById("signupForm");
const signupResult = document.getElementById("signupResult");
const jobIdInput = document.getElementById("jobIdInput");
const checkStatusBtn = document.getElementById("checkStatusBtn");
const statusResult = document.getElementById("statusResult");

signupForm.addEventListener("submit", async (e) => {
  e.preventDefault();
  signupResult.textContent = "Submitting...";
  signupResult.className = "";

  const name = document.getElementById("name").value;
  const email = document.getElementById("email").value;

  try {
    const response = await fetch(TRIGGER_SIGNUP_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, email }),
    });
    const data = await response.json();

    if (data.status === "success") {
      signupResult.textContent = `Signup successful! Your Job ID: ${data.jobId}`;
      signupResult.className = "success";
      jobIdInput.value = data.jobId;
    } else {
      signupResult.textContent = `Error: ${data.message}`;
      signupResult.className = "error";
    }
  } catch (err) {
    signupResult.textContent = "Something went wrong. Please try again.";
    signupResult.className = "error";
  }
});

checkStatusBtn.addEventListener("click", async () => {
  const jobId = jobIdInput.value.trim();
  if (!jobId) {
    statusResult.textContent = "Please enter a Job ID.";
    statusResult.className = "error";
    return;
  }

  statusResult.textContent = "Checking...";
  statusResult.className = "";

  try {
    const response = await fetch(`${GET_JOB_STATUS_URL}?jobId=${encodeURIComponent(jobId)}`);
    const data = await response.json();

    if (data.status === "success") {
      statusResult.innerHTML = `
        Overall Status: <strong>${data.overallStatus}</strong><br/>
        Notification: ${data.stages.notification}<br/>
        Audit: ${data.stages.audit}
      `;
      statusResult.className = "success";
    } else {
      statusResult.textContent = `Error: ${data.message}`;
      statusResult.className = "error";
    }
  } catch (err) {
    statusResult.textContent = "Something went wrong. Please try again.";
    statusResult.className = "error";
  }
});