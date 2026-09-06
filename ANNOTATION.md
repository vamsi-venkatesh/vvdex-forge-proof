# Multimodal Annotation

Forge's Annotation family checks structured observations over video, images,
text, structured data and audio. The public evidence covers five certified
engineering fixtures. Their certification is distinct from model performance
and from the historical software, browser and knowledge campaigns.

| Fixture | Scope | Public evidence |
| --- | --- | --- |
| Robotic video | Temporal events and sparse object tracks | [robot-video-1](exams/vvdex.annotation.robot-video-1/) |
| Image objects | Spatial annotations | [image-object-1](exams/vvdex.annotation.image-object-1/) |
| Text labeling | Spans and categorical decisions | [text-labeling-1](exams/vvdex.annotation.text-labeling-1/) |
| Structured data | Record-quality decisions | [structured-data-1](exams/vvdex.annotation.structured-data-1/) |
| Audio events | Temporal events over tones and silence | [audio-events-1](exams/vvdex.annotation.audio-events-1/) |

Each directory carries an approved descriptor, provenance, certification receipt,
aggregate report and file digests. Read `VERIFY.md` beside those artifacts or run
`./verify.sh` for the full package. The public site presents the same release at
<https://vvdexops.com/annotation/>.

The reference must pass, the baseline must fail, and targeted wrong submissions
must remain distinguishable. Task conventions control bounds, intervals, label
choices and ambiguity. The report exposes applicable aggregate reference metrics;
it does not expose reference labels or turn certification into a model score.

Annotator comparison can report disagreement and categorical agreement for
provided annotation sets. No annotator population was studied for this release,
and `agreementMetrics` remains null in the certification reports.

The robotic clip is Z22's *High-speed catching system*, recorded March 19, 2012,
available through [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:High-speed_catching_system.webm)
under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
The public proof package links this source without redistributing the media.
Source-media terms do not license VVDex's private evaluation material.

Limits: sparse frame boxes are not dense tracking; the audio fixture does not
establish speech transcription or diarization capability. CVAT XML 1.1 and Label
Studio JSON interoperability covers tested box subsets, not all platform formats.
Unsupported or lossy conversions are refused. Polygon comparison uses the
implemented vertex representation. These are small fixtures, not a production
annotation dataset, professional annotation engagement, or robotics expertise
credential. No model performance follows from their certification alone. A model campaign
must supply its own attempts, outcomes, input conditions and limitations.

## Model performance is reported separately

The September 6, 2026 GPT-5.5 CLI campaign records ten attempts on each of four
fixed tasks. Image objects passed 5/10, robotic video 0/10, text labeling 10/10
and structured data 10/10. Audio is N/A because this CLI lane does not support
audio delivery. Images were supplied as native image attachments; video was
represented by sampled still frames.

Read [the campaign scope, strict outcomes and quality metrics](ANNOTATION-MODEL-CAMPAIGN.md).
The fixture receipts above remain certification evidence; their
`modelCampaign: null` fields do not incorporate these separate model results.
