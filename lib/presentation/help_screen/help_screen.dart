
import '../../core/app_export.dart';
import './widgets/help_feature_item_widget.dart';
import './widgets/help_section_widget.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Hilfe & Anleitung',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.appBarTheme.iconTheme?.color ??
                AppTheme.textPrimaryLight,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(4.w),
            color: AppTheme.lightTheme.scaffoldBackgroundColor,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Hilfe durchsuchen...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.textSecondaryLight,
                    size: 20,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: AppTheme.textSecondaryLight,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.borderLight, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.borderLight, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppTheme.primaryLight, width: 2),
                ),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              ),
            ),
          ),

          // Help Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildHelpSections(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHelpSections() {
    List<Widget> sections = [];

    // App Überblick
    if (_searchQuery.isEmpty ||
        'app überblick getmylappen funktionen'.contains(_searchQuery)) {
      sections.add(
        HelpSectionWidget(
          title: 'App-Überblick',
          icon: 'info',
          children: [
            Text(
              'GetMyLappen ist Ihr intelligenter KI-Fahrlehrer, der Sie optimal auf die Führerscheinprüfung vorbereitet. Die App bietet eine innovative Lernumgebung mit Sprachkonversation und Textchat.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
                height: 1.4,
              ),
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Hauptfunktionen',
              description:
                  'Vollständige Lernumgebung für angehende Fahrzeugführer',
              icon: 'star',
              iconColor: AppTheme.primaryLight,
              steps: [
                'KI-gestützte Gespräche über Verkehrsregeln und Fahrtechniken',
                'Flexible Lernmodi: Sprache oder Text nach Ihren Vorlieben',
                'Personalisierte Lernfortschrittsverfolgung',
                'Gesprächsverlauf für Wiederholung wichtiger Themen',
                'Umfassende Einstellungen für optimale Lernerfahrung',
              ],
            ),
          ],
        ),
      );
    }

    // Erste Schritte
    if (_searchQuery.isEmpty ||
        'erste schritte anleitung setup'.contains(_searchQuery)) {
      sections.add(
        HelpSectionWidget(
          title: 'Erste Schritte',
          icon: 'play_arrow',
          children: [
            HelpFeatureItemWidget(
              title: 'App-Einrichtung',
              description: 'So starten Sie mit GetMyLappen',
              icon: 'settings',
              iconColor: AppTheme.successLight,
              steps: [
                'Öffnen Sie die App und durchlaufen Sie das Onboarding',
                'Erteilen Sie Mikrofon-Berechtigung für Sprachfunktionen',
                'Konfigurieren Sie Ihre API-Einstellungen (falls erforderlich)',
                'Wählen Sie Ihren bevorzugten KI-Instruktor aus',
                'Beginnen Sie Ihr erstes Gespräch über Verkehrsregeln',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Mikrofon-Berechtigung',
              description:
                  'Für optimale Spracherkennung und natürliche Gespräche',
              icon: 'mic',
              iconColor: AppTheme.warningLight,
              steps: [
                'Erlauben Sie den Mikrofon-Zugriff beim ersten Start',
                'Bei Problemen: Einstellungen → Apps → GetMyLappen → Berechtigungen',
                'Stellen Sie sicher, dass Ihr Mikrofon funktioniert',
                'Verwenden Sie die Text-Alternative, falls Sprachfunktion nicht verfügbar',
              ],
            ),
          ],
        ),
      );
    }

    // Hauptfunktionen
    if (_searchQuery.isEmpty ||
        'hauptfunktionen konversation sprache text'.contains(_searchQuery)) {
      sections.add(
        HelpSectionWidget(
          title: 'Hauptfunktionen',
          icon: 'chat',
          children: [
            HelpFeatureItemWidget(
              title: 'Sprachkonversation',
              description: 'Natürliche Gespräche mit Ihrem KI-Fahrlehrer',
              icon: 'record_voice_over',
              iconColor: AppTheme.primaryLight,
              steps: [
                'Tippen und halten Sie den Aufnahme-Button',
                'Sprechen Sie klar und deutlich über Ihr Lernthema',
                'Lassen Sie den Button los, um die Aufnahme zu beenden',
                'Warten Sie auf die KI-Antwort mit Sprachausgabe',
                'Nutzen Sie die Wiederholungsfunktion bei Bedarf',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Text-Chat',
              description: 'Schriftliche Kommunikation für präzise Fragen',
              icon: 'keyboard',
              iconColor: AppTheme.secondaryLight,
              steps: [
                'Wechseln Sie in den Text-Modus über den Modus-Schalter',
                'Geben Sie Ihre Frage in das Textfeld ein',
                'Drücken Sie den Senden-Button oder Enter',
                'Erhalten Sie detaillierte schriftliche Antworten',
                'Kopieren Sie wichtige Antworten für spätere Referenz',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Gesprächsverlauf',
              description: 'Alle Ihre Lernsitzungen an einem Ort',
              icon: 'history',
              iconColor: AppTheme.successLight,
              steps: [
                'Tippen Sie auf "Verlauf" in der unteren Navigation',
                'Durchsuchen Sie vergangene Gespräche nach Themen',
                'Nutzen Sie die Suchfunktion für spezifische Inhalte',
                'Setzen Sie unterbrochene Gespräche fort',
                'Exportieren Sie wichtige Lerninhalte',
              ],
            ),
          ],
        ),
      );
    }

    // Lernthemen
    if (_searchQuery.isEmpty ||
        'lernthemen verkehrsregeln fahrtechniken'.contains(_searchQuery)) {
      sections.add(
        HelpSectionWidget(
          title: 'Lernthemen & Inhalte',
          icon: 'school',
          children: [
            HelpFeatureItemWidget(
              title: 'Verkehrsregeln',
              description:
                  'Umfassend alle wichtigen Regelungen des Straßenverkehrs',
              icon: 'traffic',
              iconColor: AppTheme.primaryLight,
              steps: [
                'Vorfahrtsregeln: Rechts vor Links, Verkehrszeichen, Kreisverkehr',
                'Geschwindigkeitsbegrenzungen in verschiedenen Bereichen',
                'Überhol- und Wendevorschriften',
                'Parkregeln und Halteverbot',
                'Verkehrszeichen und ihre Bedeutung',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Fahrtechniken',
              description: 'Praktische Fertigkeiten für sicheres Fahren',
              icon: 'drive_eta',
              iconColor: AppTheme.secondaryLight,
              steps: [
                'Anfahren am Berg und in der Ebene',
                'Einparken: Parallel, Rückwärts, Seitlich',
                'Kurvenfahren und Spurwechsel',
                'Bremstechniken in verschiedenen Situationen',
                'Fahren bei verschiedenen Witterungsbedingungen',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Prüfungsvorbereitung',
              description:
                  'Gezieltes Training für die theoretische und praktische Prüfung',
              icon: 'quiz',
              iconColor: AppTheme.warningLight,
              steps: [
                'Fragebogen-Simulation mit erklärenden Antworten',
                'Gefahrensituationen erkennen und bewerten',
                'Praxisnahe Szenarien und Lösungsansätze',
                'Tipps zur Prüfungsangst und mentalen Vorbereitung',
                'Häufige Fehlerquellen und deren Vermeidung',
              ],
            ),
          ],
        ),
      );
    }

    // Einstellungen
    if (_searchQuery.isEmpty ||
        'einstellungen konfiguration audio sprache'.contains(_searchQuery)) {
      sections.add(
        HelpSectionWidget(
          title: 'Einstellungen & Konfiguration',
          icon: 'settings',
          children: [
            HelpFeatureItemWidget(
              title: 'Audio-Einstellungen',
              description: 'Optimieren Sie Ihre Sprach- und Hörqualität',
              icon: 'volume_up',
              iconColor: AppTheme.primaryLight,
              steps: [
                'Mikrofon-Empfindlichkeit anpassen',
                'Lautstärke für Sprachausgabe einstellen',
                'Rauschunterdrückung aktivieren/deaktivieren',
                'Bevorzugtes Audiogerät auswählen',
                'Audio-Qualität nach Verbindungsgeschwindigkeit wählen',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Spracheinstellungen',
              description: 'Passen Sie die App an Ihre Sprachpräferenzen an',
              icon: 'language',
              iconColor: AppTheme.secondaryLight,
              steps: [
                'Deutsche Spracherkennung optimieren',
                'Regionale Dialekte und Akzente berücksichtigen',
                'Fachbegriffe und Verkehrssprache trainieren',
                'Geschwindigkeit der Sprachausgabe anpassen',
                'Deutsche Tastatur für Texteingabe aktivieren',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Datenschutz & Sicherheit',
              description: 'Ihre Daten sind sicher und geschützt',
              icon: 'security',
              iconColor: AppTheme.successLight,
              steps: [
                'Gesprächsspeicherung nach DSGVO-Richtlinien',
                'Lokale Datenspeicherung ohne Cloudübertragung',
                'Biometrische Sicherheit für sensible Einstellungen',
                'Automatische Löschung alter Gespräche',
                'Keine Weitergabe persönlicher Daten an Dritte',
              ],
            ),
          ],
        ),
      );
    }

    // API-Konfiguration
    if (_searchQuery.isEmpty ||
        'api konfiguration elevenlabs verbindung'.contains(_searchQuery)) {
      sections.add(
        HelpSectionWidget(
          title: 'API-Konfiguration',
          icon: 'settings_remote',
          children: [
            HelpFeatureItemWidget(
              title: 'ElevenLabs-Einrichtung',
              description: 'Verbinden Sie die App mit Ihrem ElevenLabs-Konto',
              icon: 'link',
              iconColor: AppTheme.primaryLight,
              steps: [
                'Registrieren Sie sich bei ElevenLabs.io',
                'Kopieren Sie Ihren API-Schlüssel aus dem Dashboard',
                'Fügen Sie den API-Schlüssel in die App ein',
                'Wählen Sie Ihre bevorzugte Stimme aus',
                'Testen Sie die Verbindung mit dem Test-Button',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Verbindungsprobleme lösen',
              description: 'Hilfe bei API-Verbindungsproblemen',
              icon: 'troubleshoot',
              iconColor: AppTheme.errorLight,
              steps: [
                'Überprüfen Sie Ihre Internetverbindung',
                'Validieren Sie den API-Schlüssel auf Gültigkeit',
                'Stellen Sie sicher, dass Ihr ElevenLabs-Guthaben ausreicht',
                'Nutzen Sie den Mock-Modus für Tests ohne API-Verbrauch',
                'Kontaktieren Sie den Support bei anhaltenden Problemen',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Erweiterte Einstellungen',
              description: 'Feinabstimmung für optimale Leistung',
              icon: 'tune',
              iconColor: AppTheme.warningLight,
              steps: [
                'Antwortgeschwindigkeit der KI anpassen',
                'Stimmenmodell für verschiedene Szenarien wählen',
                'Audioqualität nach Verbindungsgeschwindigkeit',
                'Timeout-Einstellungen für stabile Verbindung',
                'Automatische Wiederverbindung aktivieren',
              ],
            ),
          ],
        ),
      );
    }

    // Häufige Probleme
    if (_searchQuery.isEmpty ||
        'probleme fehler troubleshooting lösung'.contains(_searchQuery)) {
      sections.add(
        HelpSectionWidget(
          title: 'Häufige Probleme & Lösungen',
          icon: 'help',
          children: [
            HelpFeatureItemWidget(
              title: 'Mikrofon funktioniert nicht',
              description: 'Spracherkennung oder Aufnahme funktioniert nicht',
              icon: 'mic_off',
              iconColor: AppTheme.errorLight,
              steps: [
                'Prüfen Sie die Mikrofon-Berechtigung in den Geräteeinstellungen',
                'Starten Sie die App neu und gewähren Sie die Berechtigung',
                'Testen Sie das Mikrofon in anderen Apps',
                'Überprüfen Sie, ob das Mikrofon nicht blockiert oder stumm ist',
                'Nutzen Sie den Text-Modus als Alternative',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Keine Internetverbindung',
              description:
                  'App funktioniert offline oder mit schlechter Verbindung',
              icon: 'wifi_off',
              iconColor: AppTheme.warningLight,
              steps: [
                'Überprüfen Sie Ihre WLAN- oder Mobilfunkverbindung',
                'Wechseln Sie zwischen WLAN und mobilen Daten',
                'Starten Sie Ihren Router oder setzen Sie Netzwerkeinstellungen zurück',
                'Nutzen Sie den Offline-Modus für gespeicherte Gespräche',
                'Warten Sie auf stabile Verbindung für neue Gespräche',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'App stürzt ab oder reagiert nicht',
              description: 'Performance-Probleme und Stabilitätsprobleme',
              icon: 'error',
              iconColor: AppTheme.errorLight,
              steps: [
                'Schließen Sie die App vollständig und starten Sie sie neu',
                'Starten Sie Ihr Gerät neu',
                'Löschen Sie den App-Cache in den Geräteeinstellungen',
                'Stellen Sie sicher, dass genügend Speicherplatz verfügbar ist',
                'Aktualisieren Sie die App auf die neueste Version',
              ],
            ),
          ],
        ),
      );
    }

    // Tipps und Tricks
    if (_searchQuery.isEmpty ||
        'tipps tricks optimierung lernen'.contains(_searchQuery)) {
      sections.add(
        HelpSectionWidget(
          title: 'Tipps & Tricks',
          icon: 'lightbulb',
          children: [
            HelpFeatureItemWidget(
              title: 'Effektiv lernen mit der App',
              description: 'Maximieren Sie Ihren Lernerfolg',
              icon: 'psychology',
              iconColor: AppTheme.successLight,
              steps: [
                'Stellen Sie spezifische Fragen statt allgemeine Themen',
                'Nutzen Sie die Wiederholungsfunktion für wichtige Antworten',
                'Kombinieren Sie Sprach- und Text-Modus je nach Situation',
                'Führen Sie regelmäßige kurze Lernsitzungen durch',
                'Notieren Sie sich wichtige Punkte aus den Gesprächen',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Optimale Sprachqualität',
              description: 'Bessere Erkennung und klarere Kommunikation',
              icon: 'record_voice_over',
              iconColor: AppTheme.primaryLight,
              steps: [
                'Sprechen Sie in einer ruhigen Umgebung',
                'Halten Sie das Gerät etwa 15-20 cm vom Mund entfernt',
                'Sprechen Sie klar und in normalem Tempo',
                'Vermeiden Sie Hintergrundgeräusche und Musik',
                'Nutzen Sie ein externes Mikrofon für beste Qualität',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Datensparend nutzen',
              description: 'Optimieren Sie den Datenverbrauch',
              icon: 'data_usage',
              iconColor: AppTheme.warningLight,
              steps: [
                'Nutzen Sie WLAN für längere Lernsitzungen',
                'Reduzieren Sie die Audioqualität bei langsamer Verbindung',
                'Laden Sie wichtige Gespräche für Offline-Nutzung herunter',
                'Begrenzen Sie die Länge einzelner Sprachnachrichten',
                'Nutzen Sie den Text-Modus für geringeren Datenverbrauch',
              ],
            ),
          ],
        ),
      );
    }

    // Kontakt und Support
    if (_searchQuery.isEmpty ||
        'kontakt support hilfe feedback'.contains(_searchQuery)) {
      sections.add(
        HelpSectionWidget(
          title: 'Kontakt & Support',
          icon: 'contact_support',
          children: [
            HelpFeatureItemWidget(
              title: 'Support kontaktieren',
              description: 'Erhalten Sie persönliche Hilfe bei Problemen',
              icon: 'support_agent',
              iconColor: AppTheme.primaryLight,
              steps: [
                'Dokumentieren Sie das Problem mit Screenshots',
                'Notieren Sie die Fehlermeldung oder das Verhalten',
                'Geben Sie Ihr Gerätemodell und Betriebssystem an',
                'Beschreiben Sie die Schritte zur Problemreproduzierung',
                'Senden Sie eine E-Mail mit allen Informationen',
              ],
            ),
            SizedBox(height: 2.h),
            HelpFeatureItemWidget(
              title: 'Feedback und Verbesserungsvorschläge',
              description: 'Helfen Sie uns, die App zu verbessern',
              icon: 'feedback',
              iconColor: AppTheme.successLight,
              steps: [
                'Teilen Sie Ihre Lernerfahrungen mit uns',
                'Schlagen Sie neue Funktionen oder Themen vor',
                'Bewerten Sie die App in Ihrem App Store',
                'Empfehlen Sie die App an andere Fahrschüler',
                'Nehmen Sie an Umfragen zur App-Entwicklung teil',
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryLight.withAlpha(77)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'info',
                        color: AppTheme.primaryLight,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Wichtiger Hinweis',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'GetMyLappen ersetzt nicht den professionellen Fahrunterricht oder die offizielle Fahrschule. Die App dient als ergänzendes Lernwerkzeug zur Vorbereitung auf die Theorieprüfung und zum Verständnis von Verkehrsregeln.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryLight,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (sections.isEmpty) {
      sections.add(
        Container(
          padding: EdgeInsets.all(8.w),
          child: Column(
            children: [
              CustomIconWidget(
                iconName: 'search_off',
                color: AppTheme.textSecondaryLight,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                'Keine Hilfe-Themen gefunden',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Versuchen Sie einen anderen Suchbegriff oder löschen Sie die Suche.',
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return sections;
  }
}
