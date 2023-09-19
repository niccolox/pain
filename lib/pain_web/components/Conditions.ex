defmodule PainWeb.Components.Conditions do
  use Surface.LiveComponent

  @languages ~w[ English Chinese ]

  data language, :string, default: "Chinese", values!: ["English", "Chinese"]

  def handle_event "choose_language", params, socket do
    {:noreply, socket |> assign(:language, params["lang"]) }
  end

  def render(assigns) do
    langs = @languages
    ~F"""
    <style>
      ul, ol { padding-left: 2rem; line-height: 1.1rem; }
      li { margin-bottom: 0.4rem; }
      ul { list-style: disc; }
      ol { list-style: decimal; }
      .legal { margin-bottom: 2rem; }
      input[checked] { background: #117864; }
      hr { margin-bottom: 2rem; }
    </style>

    <div class="choose-lang">
      {#for lang <- langs}
        <label class="label">
          <span>{lang}</span> 
          <input name="language" type="radio" class="radio" :on-click="choose_language"
            checked={@language == lang} phx-value-lang={lang} />
        </label>
      {/for}
    </div>

    <hr/>

    <h2>Terms &amp; Conditions ({@language}):</h2>

    <div class="legal">
      {#if @language == "English"}
        <p>
        Our customers’ health, satisfaction, and experience are our utmost
          priority and we aim to give you all that you need and have you leave
          us feeling refreshed and rejuvenated. Thus, we understand the desire
          to extend your initial scheduled time. However, we ask that you check
          with the front desk whether there is sufficient time to extend your
          appointment before doing so, out of courtesy for the next scheduled
          client. We aim to reduce the wait times and ensure everyone is seen
          in a timely manner.
        </p>

        <ol>
          <li>I give my permission to receive massage therapy.</li>
          <li>I understand that therapeutic massage is not a substitute for traditional medical treatment or medications.</li>
          <li>I understand that the massage therapist does not diagnose illnesses or injuries, or prescribe medications.</li>
          <li>
            I understand the risks associated with massage therapy include, but are not limited to:
            <ul>
            <li>Superficial bruising</li>
            <li>Short-term muscle soreness</li>
            <li>Exacerbation of undiscovered injury</li>
            </ul>
            <br/>
            I, therefore, release the company and the individual massage therapist
              from all liability concerning these injuries that may occur
              during the massage session.
            </li>
            <li>I understand the importance of informing my massage therapist
              of all medical conditions and medications I am taking, and to
              let the massage therapist know about any changes to these.
                 <br>
                 I understand that there may be additional risks based on my physical condition.</li>
                 <li>I understand that it is my responsibility to inform my massage therapist of any discomfort I may feel during the massage session so he/she may adjust accordingly.</li>
                 <li>I understand that I or the massage therapist may terminate the session at any time. </li>
                 <li>I have been given a chance to ask questions about the massage therapy session and/or Chinese Medical Treatment and my questions have been answered.</li>
                 </ol>
      {#elseif @language == "Chinese"}
        <ol>
          <li>我同意接受按摩治疗。</li>
          <li>我了解治疗性按摩不能替代传统医学治疗或药物治疗。</li>
          <li>我了解按摩治疗师不会诊断疾病或受伤，也不会开药。</li>
          <li>我了解与按摩疗法相关的风险包括但不限于：<br>
          <ul>
            <li>表面瘀伤</li>
            <li>短期肌肉酸痛</li>
            <li>未发现伤害的恶化</li>
          </ul>
          因此，我免除公司和个人按摩治疗师对按摩期间可能发生的这些伤害的所有责任。</li>
          <li>我了解将我正在服用的所有医疗状况和药物告知我的按摩治疗师的重要性，并让按摩治疗师知道这些变化的重要性。<br>
          我了解根据我的身体状况可能会有额外的风险。</li>
          <li>我明白，我有责任将我在按摩过程中可能感到的任何不适通知我的按摩治疗师，以便他/她做出相应的调整。</li>
          <li>我明白我或按摩治疗师可以随时终止疗程。</li>
          <li>我有机会询问有关按摩疗法的问题，并且我的问题已得到解答。</li>
        </ol>
      {/if}
    </div>
    """
  end
end
