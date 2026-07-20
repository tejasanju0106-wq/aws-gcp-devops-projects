const TRIGGER_SIGNUP_URL = "https://us-central1-devops-learning-p1-teja.cloudfunctions.net/trigger-signup";
const GET_JOB_STATUS_URL = "https://us-central1-devops-learning-p1-teja.cloudfunctions.net/get-job-status";

const POLL_INTERVAL_MS = 2000;
const MAX_POLL_ATTEMPTS = 12; // ~24 seconds before giving up

const signupForm = document.getElementById("signupForm");
const statusPanel = document.getElementById("statusPanel");
const spinner = document.getElementById("spinner");
const statusIcon = document.getElementById("statusIcon");
const statusMessage = document.getElementById("statusMessage");
const retryBtn = document.getElementById("retryBtn");

function showForm() {
  signupForm.classList.remove("hidden");
  statusPanel.classList.add("hidden");
}

function showProcessing(message) {
  signupForm.classList.add("hidden");
  statusPanel.classList.remove("hidden");
  spinner.classList.remove("hidden");
  statusIcon.classList.add("hidden");
  retryBtn.classList.add("hidden");
  statusMessage.textContent = message;
}

function showResult(type, message) {
  spinner.classList.add("hidden");
  statusIcon.classList.remove("hidden");
  statusIcon.className = `status-icon ${type}`;
  statusIcon.textContent = type === "success" ? "✓" : "!";
  statusMessage.textContent = message;
  if (type === "error") {
    retryBtn.classList.remove("hidden");
  }
}

async function pollJobStatus(jobId, attempt = 1) {
  try {
    const response = await fetch(`${GET_JOB_STATUS_URL}?jobId=${encodeURIComponent(jobId)}`);
    const data = await response.json();

    if (data.status !== "success") {
      showResult("error", "Something went wrong. Please try again.");
      return;
    }

    const overallStatus = data.overallStatus;

    if (overallStatus === "COMPLETED") {
      showResult("success", "Welcome! Your account has been created successfully.");
      return;
    }

    if (overallStatus === "VALIDATION_FAILED") {
      showResult("error", "We couldn't verify that email address. Please check it and try again.");
      return;
    }

    if (overallStatus === "FAILED" || overallStatus === "PARTIAL_FAILED") {
      showResult("error", "Something went wrong while setting up your account. Please try again.");
      return;
    }

    if (overallStatus === "RECEIVED" || overallStatus === "VALIDATING") {
      showProcessing("Verifying your details...");
    } else if (overallStatus === "VALIDATED" || overallStatus === "PUBLISHED") {
      showProcessing("Setting up your account...");
    }

    if (attempt >= MAX_POLL_ATTEMPTS) {
      showResult("error", "This is taking longer than expected. Please try again in a moment.");
      return;
    }

    setTimeout(() => pollJobStatus(jobId, attempt + 1), POLL_INTERVAL_MS);
  } catch (err) {
    showResult("error", "Something went wrong. Please try again.");
  }
}

signupForm.addEventListener("submit", async (e) => {
  e.preventDefault();

  const name = document.getElementById("name").value;
  const email = document.getElementById("email").value;

  showProcessing("Creating your account...");

  try {
    const response = await fetch(TRIGGER_SIGNUP_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, email }),
    });
    const data = await response.json();

    if (data.status === "success") {
      pollJobStatus(data.jobId);
    } else {
      showResult("error", "Something went wrong. Please try again.");
    }
  } catch (err) {
    showResult("error", "Something went wrong. Please try again.");
  }
});

retryBtn.addEventListener("click", () => {
  signupForm.reset();
  showForm();
});