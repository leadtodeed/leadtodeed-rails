import { LeadtodeedPhone } from "leadtodeed-widget"
import { Controller } from "@hotwired/stimulus"

// --- SVG Icons ---

const USER_ICON = `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M20 21c0-3.87-3.58-7-8-7s-8 3.13-8 7"/></svg>`

const PHONE_ICON = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>`

const PHONE_OFF_ICON = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.68 13.31a16 16 0 0 0 3.41 2.6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91"/><line x1="1" y1="1" x2="23" y2="23"/></svg>`

// --- Color helpers ---

function hexToRgb(hex) {
  const m = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
  return m ? [parseInt(m[1], 16), parseInt(m[2], 16), parseInt(m[3], 16)] : [139, 92, 246]
}

function lighten(hex, amount) {
  const [r, g, b] = hexToRgb(hex)
  return `rgb(${Math.round(r + (255 - r) * amount)}, ${Math.round(g + (255 - g) * amount)}, ${Math.round(b + (255 - b) * amount)})`
}

function shadow(hex, alpha) {
  const [r, g, b] = hexToRgb(hex)
  return `rgba(${r}, ${g}, ${b}, ${alpha})`
}

function escapeHtml(str) {
  const div = document.createElement("div")
  div.textContent = str || ""
  return div.innerHTML
}

// --- Inject keyframes once ---

function ensureKeyframes() {
  if (document.getElementById("leadtodeed-keyframes")) return
  const style = document.createElement("style")
  style.id = "leadtodeed-keyframes"
  style.textContent = `
    @keyframes leadtodeed-slide-up {
      from { transform: translateY(20px); opacity: 0; }
      to { transform: translateY(0); opacity: 1; }
    }
    @keyframes leadtodeed-pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.5; }
    }
  `
  document.head.appendChild(style)
}

// --- Shared card builder ---

function buildCard(color) {
  ensureKeyframes()
  const borderColor = lighten(color, 0.3)

  const wrapper = document.createElement("div")
  Object.assign(wrapper.style, {
    position: "fixed",
    bottom: "24px",
    right: "24px",
    zIndex: "999999",
    fontFamily: "Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
    animation: "leadtodeed-slide-up 0.25s ease-out",
  })

  const card = document.createElement("div")
  Object.assign(card.style, {
    background: "white",
    border: `1px solid ${borderColor}`,
    borderRadius: "16px",
    boxShadow: `0 0 12px ${shadow(color, 0.25)}`,
    padding: "24px 16px 16px",
    width: "260px",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    gap: "16px",
  })

  wrapper.appendChild(card)
  return { wrapper, card }
}

function buildAvatar() {
  const avatar = document.createElement("div")
  Object.assign(avatar.style, {
    background: "#f1f5f9",
    borderRadius: "50%",
    padding: "8px",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
  })
  avatar.innerHTML = USER_ICON
  return avatar
}

function buildNameBlock(displayName, subtitle, animated) {
  const block = document.createElement("div")
  Object.assign(block.style, { textAlign: "center", width: "100%" })

  const nameEl = document.createElement("p")
  Object.assign(nameEl.style, {
    fontSize: "18px", fontWeight: "600", color: "#0f172a", margin: "0", lineHeight: "1.2",
  })
  nameEl.textContent = displayName

  const subEl = document.createElement("p")
  Object.assign(subEl.style, {
    fontSize: "14px", fontWeight: "600", color: "#94a3b8", margin: "4px 0 0", lineHeight: "1.2",
    ...(animated ? { animation: "leadtodeed-pulse 2s ease-in-out infinite" } : {}),
  })
  subEl.textContent = subtitle
  subEl.dataset.role = "subtitle"

  block.append(nameEl, subEl)
  return block
}

function buildTopSection(displayName, subtitle, animated) {
  const top = document.createElement("div")
  Object.assign(top.style, {
    display: "flex", flexDirection: "column", alignItems: "center", gap: "12px", width: "100%",
  })
  top.append(buildAvatar(), buildNameBlock(displayName, subtitle, animated))
  return top
}

function buildButtonGroup({ icon, label, bgColor, borderColor, iconColor, labelColor, borderRadius, onClick }) {
  const group = document.createElement("div")
  Object.assign(group.style, {
    display: "flex", flexDirection: "column", alignItems: "center", gap: "4px", cursor: "pointer",
  })

  const btn = document.createElement("button")
  Object.assign(btn.style, {
    width: "36px", height: "36px", borderRadius, border: `1px solid ${borderColor}`,
    background: bgColor, color: iconColor, display: "flex", alignItems: "center",
    justifyContent: "center", cursor: "pointer", padding: "0", transition: "transform 0.1s",
  })
  btn.innerHTML = icon
  btn.addEventListener("mousedown", () => { btn.style.transform = "scale(0.92)" })
  btn.addEventListener("mouseup", () => { btn.style.transform = "scale(1)" })
  btn.addEventListener("mouseleave", () => { btn.style.transform = "scale(1)" })
  btn.addEventListener("click", onClick)

  const labelEl = document.createElement("span")
  Object.assign(labelEl.style, {
    fontSize: "12px", fontWeight: "600", color: labelColor, lineHeight: "1",
  })
  labelEl.textContent = label

  group.append(btn, labelEl)
  return group
}

function buildButtonsRow(...groups) {
  const row = document.createElement("div")
  Object.assign(row.style, {
    display: "flex", justifyContent: "center", alignItems: "flex-start", gap: "40px", width: "100%",
  })
  row.append(...groups)
  return row
}

function buildTimerEl() {
  const timer = document.createElement("p")
  Object.assign(timer.style, {
    fontSize: "24px", fontWeight: "600", color: "#0f172a", margin: "0", lineHeight: "1.2",
    fontVariantNumeric: "tabular-nums",
  })
  timer.dataset.role = "timer"
  timer.textContent = "00:00"
  return timer
}

function formatTime(seconds) {
  const m = Math.floor(seconds / 60).toString().padStart(2, "0")
  const s = (seconds % 60).toString().padStart(2, "0")
  return `${m}:${s}`
}

// --- Unified call UI Stimulus controller ---

class LeadtodeedCallController extends Controller {
  connect() {
    this._popup = null
    this._timer = null
    this._seconds = 0
    this._color = document.querySelector('meta[name="leadtodeed-primary-color"]')?.content || "#8B5CF6"

    this._handlers = {
      "leadtodeed:incoming-call": this._onIncoming.bind(this),
      "leadtodeed:call-started": this._onCallStarted.bind(this),
      "leadtodeed:call-progress": this._onCallProgress.bind(this),
      "leadtodeed:call-connected": this._onCallConnected.bind(this),
      "leadtodeed:call-ended": this._onCallEnded.bind(this),
    }
    for (const [evt, fn] of Object.entries(this._handlers)) {
      window.addEventListener(evt, fn)
    }
  }

  disconnect() {
    for (const [evt, fn] of Object.entries(this._handlers)) {
      window.removeEventListener(evt, fn)
    }
    this._removePopup()
  }

  // --- Incoming call ---

  _onIncoming(event) {
    const { callerName, callerNumber } = event.detail
    this._showIncoming(callerName || callerNumber || "Unknown", callerNumber)
  }

  _showIncoming(displayName) {
    this._removePopup()
    const c = this._color
    const { wrapper, card } = buildCard(c)
    const spacer = document.createElement("div")
    spacer.style.height = "24px"

    card.append(
      buildTopSection(displayName, "is calling...", true),
      spacer,
      buildButtonsRow(
        buildButtonGroup({
          icon: PHONE_OFF_ICON, label: "Reject", bgColor: "white",
          borderColor: "#cbd5e1", iconColor: "#64748b", labelColor: "#64748b",
          borderRadius: "8px",
          onClick: () => { window.leadtodeedPhone?.reject(); this._removePopup() },
        }),
        buildButtonGroup({
          icon: PHONE_ICON, label: "Answer", bgColor: c,
          borderColor: c, iconColor: "white", labelColor: c,
          borderRadius: "50%",
          onClick: () => { window.leadtodeedPhone?.answer(); this._removePopup() },
        }),
      ),
    )

    document.body.appendChild(wrapper)
    this._popup = wrapper
  }

  // --- Outgoing call ---

  _onCallStarted(event) {
    const { number, direction } = event.detail
    if (direction === "outgoing") {
      this._showOutgoing(number)
    }
  }

  _showOutgoing(number) {
    this._removePopup()
    const c = this._color
    const { wrapper, card } = buildCard(c)
    const spacer = document.createElement("div")
    spacer.style.height = "24px"

    card.append(
      buildTopSection(escapeHtml(number), "Calling...", true),
      spacer,
      buildButtonsRow(
        buildButtonGroup({
          icon: PHONE_OFF_ICON, label: "Hang up", bgColor: "white",
          borderColor: "#cbd5e1", iconColor: "#ef4444", labelColor: "#ef4444",
          borderRadius: "8px",
          onClick: () => { window.leadtodeedPhone?.hangup() },
        }),
      ),
    )

    document.body.appendChild(wrapper)
    this._popup = wrapper
  }

  // --- Ringing ---

  _onCallProgress() {
    if (!this._popup) return
    const sub = this._popup.querySelector('[data-role="subtitle"]')
    if (sub) sub.textContent = "Ringing..."
  }

  // --- Connected ---

  _onCallConnected(event) {
    const { number } = event.detail
    this._showConnected(number)
  }

  _showConnected(number) {
    this._removePopup()
    const c = this._color
    const { wrapper, card } = buildCard(c)

    const top = document.createElement("div")
    Object.assign(top.style, {
      display: "flex", flexDirection: "column", alignItems: "center", gap: "12px", width: "100%",
    })
    top.append(buildAvatar(), buildNameBlock(escapeHtml(number), "Connected", false))

    const timer = buildTimerEl()
    const spacer = document.createElement("div")
    spacer.style.height = "8px"

    card.append(
      top,
      timer,
      spacer,
      buildButtonsRow(
        buildButtonGroup({
          icon: PHONE_OFF_ICON, label: "Hang up", bgColor: "white",
          borderColor: "#cbd5e1", iconColor: "#ef4444", labelColor: "#ef4444",
          borderRadius: "8px",
          onClick: () => { window.leadtodeedPhone?.hangup() },
        }),
      ),
    )

    document.body.appendChild(wrapper)
    this._popup = wrapper
    this._startTimer()
  }

  // --- Ended ---

  _onCallEnded() {
    this._removePopup()
  }

  // --- Timer ---

  _startTimer() {
    this._stopTimer()
    this._seconds = 0
    this._timer = setInterval(() => {
      this._seconds++
      const el = this._popup?.querySelector('[data-role="timer"]')
      if (el) el.textContent = formatTime(this._seconds)
    }, 1000)
  }

  _stopTimer() {
    if (this._timer) {
      clearInterval(this._timer)
      this._timer = null
    }
  }

  _removePopup() {
    this._stopTimer()
    if (this._popup) {
      this._popup.remove()
      this._popup = null
    }
  }
}

// --- Click-to-call Stimulus controller ---
// Intercepts clicks on all a[href^="tel:"] links and routes them through WebRTC.

class LeadtodeedController extends Controller {
  connect() {
    this._onClick = this._handleClick.bind(this)
    document.addEventListener("click", this._onClick, true)
  }

  disconnect() {
    document.removeEventListener("click", this._onClick, true)
  }

  _handleClick(event) {
    const link = event.target.closest('a[href^="tel:"]')
    if (!link) return
    if (!window.leadtodeedPhone) return

    event.preventDefault()
    const number = link.getAttribute("href").replace(/^tel:/, "").trim()
    if (number) window.leadtodeedPhone.call(number)
  }
}

// --- Register controllers ---

if (window.Stimulus) {
  window.Stimulus.register("leadtodeed", LeadtodeedController)
  window.Stimulus.register("leadtodeed-call", LeadtodeedCallController)
}

// --- Initialize phone widget ---

const leadtodeedUrl = document.querySelector('meta[name="leadtodeed-url"]')?.content
if (leadtodeedUrl) {
  const dispatch = (name, detail) =>
    window.dispatchEvent(new CustomEvent(name, { detail }))

  const phone = new LeadtodeedPhone({
    leadtodeedUrl,
    tokenUrl: "/api/leadtodeed/token",
    onIncomingCall: (d) => dispatch("leadtodeed:incoming-call", d),
    onCallStarted: (d) => dispatch("leadtodeed:call-started", d),
    onCallProgress: (d) => dispatch("leadtodeed:call-progress", d),
    onCallConnected: (d) => dispatch("leadtodeed:call-connected", d),
    onCallEnded: (d) => dispatch("leadtodeed:call-ended", d),
    onError: (err) => console.error("[LeadtodeedPhone]", err),
  })

  phone.connect().catch((err) => console.error("[LeadtodeedPhone] connect failed:", err))

  window.leadtodeedPhone = phone
  window.leadtodeedCall = (number) => phone.call(number)
}
