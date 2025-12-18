import display from '@ohos.display';

function offsetIsoDate(offsetDays: number): string {
  const date = new Date();
  date.setHours(0, 0, 0, 0);
  date.setDate(date.getDate() + offsetDays);
  return date.toISOString().split('T')[0];
}

type TaskSection = 'today' | 'upcoming' | 'inbox';

interface Checklist {
  done: number;
  total: number;
}

interface Task {
  id: number;
  title: string;
  deadline?: string;
  section: TaskSection;
  completed: boolean;
  checklist: Checklist;
}

interface SectionMeta {
  key: TaskSection;
  title: string;
  accent: string;
}

interface Palette {
  background: Color | string;
  card: Color | string;
  subtleCard: Color | string;
  primaryText: Color | string;
  secondaryText: Color | string;
  mutedText: Color | string;
  accent: Color | string;
  divider: Color | string;
  shadow: Color | string;
  buttonText: Color | string;
}

@Entry
@Component
struct Index {
  @State tasks: Task[] = [
    {
      id: 1,
      title: 'Send the project update to the team',
      deadline: offsetIsoDate(0),
      section: 'today',
      completed: false,
      checklist: { done: 1, total: 3 }
    },
    {
      id: 2,
      title: 'Refine product roadmap draft',
      deadline: offsetIsoDate(2),
      section: 'upcoming',
      completed: false,
      checklist: { done: 0, total: 2 }
    },
    {
      id: 3,
      title: 'Book venue for offsite',
      deadline: offsetIsoDate(7),
      section: 'upcoming',
      completed: false,
      checklist: { done: 2, total: 4 }
    },
    {
      id: 4,
      title: 'Capture feedback from discovery calls',
      deadline: undefined,
      section: 'inbox',
      completed: false,
      checklist: { done: 0, total: 1 }
    }
  ];

  @State quickTitle: string = '';
  @State quickDeadline: string = '';
  @State quickSection: TaskSection = 'today';
  @State editingTaskId: number | undefined = undefined;
  @State editingTitle: string = '';
  @State layoutIsWide: boolean = false;

  private sections: SectionMeta[] = [
    { key: 'today', title: 'Today', accent: '#5D9DF6' },
    { key: 'upcoming', title: 'Upcoming', accent: '#5BC89A' },
    { key: 'inbox', title: 'Inbox', accent: '#D0B36A' }
  ];

  aboutToAppear() {
    display.getDefaultDisplay()
      .then((device) => {
        this.layoutIsWide = device.width >= 720;
      })
      .catch(() => {
        this.layoutIsWide = false;
      });
  }

  build() {
    Column() {
      this.renderHeader();
      this.renderQuickEntry();

      List({ space: 14 }) {
        ForEach(this.sections, (section: SectionMeta) => {
          ListItem() {
            this.renderSection(section);
          }
        }, (section: SectionMeta) => section.key);
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ top: 8, bottom: 32 });
    }
    .padding({ top: 24, bottom: 24, left: this.horizontalPadding(), right: this.horizontalPadding() })
    .backgroundColor(this.palette().background)
    .height('100%')
    .width('100%');
  }

  @Builder
  private renderHeader() {
    Row() {
      Column() {
        Text('Plannist')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.palette().primaryText)
        Text('Capture today, plan ahead, stay calm')
          .fontSize(14)
          .fontColor(this.palette().secondaryText)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Center)

      Blank().layoutWeight(1)

      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text('+')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.palette().buttonText)
      }
      .width(46)
      .height(46)
      .backgroundColor(this.palette().accent)
      .borderRadius(23)
      .shadow({ radius: 12, color: this.palette().shadow })
      .onClick(() => this.addQuickTask())
    }
    .width('100%')
    .margin({ bottom: 18 })
  }

  @Builder
  private renderQuickEntry() {
    Column() {
      Text('Quick Entry')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.palette().primaryText)
        .margin({ bottom: 10 })

      Column() {
        TextInput({ placeholder: 'Add a task…', text: this.quickTitle })
          .placeholderColor(this.palette().mutedText)
          .fontSize(16)
          .caretColor(this.palette().accent)
          .backgroundColor(Color.Transparent)
          .onChange((value: string) => {
            this.quickTitle = value;
          })
          .width('100%')
          .margin({ bottom: 10 })

        Row() {
          Row() {
            ForEach(this.sections, (section: SectionMeta) => {
              Button({ type: ButtonType.Capsule, stateEffect: true }) {
                Text(section.title)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.quickSection === section.key ? this.palette().buttonText : this.palette().primaryText)
              }
              .height(38)
              .margin({ right: 8 })
              .padding({ left: 14, right: 14 })
              .backgroundColor(this.quickSection === section.key ? section.accent : this.palette().card)
              .border({ width: 1, color: this.palette().divider })
              .shadow({ radius: this.quickSection === section.key ? 8 : 0, color: this.palette().shadow })
              .onClick(() => {
                this.quickSection = section.key;
              })
            }, (section: SectionMeta) => section.key)
          }
          .alignItems(VerticalAlign.Center)
          .layoutWeight(1)

          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Text('Add')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.palette().buttonText)
          }
          .height(42)
          .padding({ left: 18, right: 18 })
          .backgroundColor(this.palette().accent)
          .shadow({ radius: 12, color: this.palette().shadow })
          .onClick(() => this.addQuickTask())
        }
        .alignItems(VerticalAlign.Center)

        TextInput({ placeholder: 'Deadline (YYYY-MM-DD, optional)', text: this.quickDeadline })
          .placeholderColor(this.palette().mutedText)
          .fontColor(this.palette().primaryText)
          .caretColor(this.palette().accent)
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .margin({ top: 10 })
          .onChange((value: string) => {
            this.quickDeadline = value;
          })
      }
      .padding(16)
      .backgroundColor(this.palette().card)
      .borderRadius(18)
      .shadow({ radius: 16, color: this.palette().shadow, offsetY: 4 })
    }
    .margin({ bottom: 18 })
    .width('100%')
  }

  @Builder
  private renderSection(section: SectionMeta) {
    Column() {
      Row() {
        Row() {
          Text(section.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.palette().primaryText)
          Text(`${this.tasks.filter((item: Task) => item.section === section.key && item.completed).length}/${this.tasks.filter((item: Task) => item.section === section.key).length}`)
            .fontSize(14)
            .fontColor(this.palette().mutedText)
            .margin({ left: 8 })
        }

        Blank().layoutWeight(1)

        Text('Add')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(section.accent)
          .onClick(() => {
            this.quickSection = section.key;
            this.addQuickTask();
          })
      }
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 10 })

      if (this.tasks.filter((task: Task) => task.section === section.key).length === 0) {
        this.renderEmptyState(section);
      } else {
        Column() {
          ForEach(this.tasks.filter((task: Task) => task.section === section.key), (task: Task) => {
            this.renderTaskRow(task, section);
          }, (task: Task) => task.id.toString());
        }
      }
    }
    .padding(16)
    .backgroundColor(this.palette().card)
    .borderRadius(18)
    .shadow({ radius: 16, color: this.palette().shadow, offsetY: 4 })
  }

  @Builder
  private renderEmptyState(section: SectionMeta) {
    Column() {
      Text('Nothing here yet')
        .fontSize(14)
        .fontColor(this.palette().secondaryText)
      Text('Tap Add to capture your next step')
        .fontSize(12)
        .fontColor(this.palette().mutedText)
        .margin({ top: 4 })
    }
    .padding({ top: 18, bottom: 18 })
    .width('100%')
    .backgroundColor(this.palette().subtleCard)
    .borderRadius(12)
    .border({ width: 1, color: this.palette().divider })
  }

  @Builder
  private renderTaskRow(task: Task, section: SectionMeta) {
    Row() {
      Checkbox()
        .select(task.completed)
        .selectedColor(section.accent)
        .unselectedColor(this.palette().divider)
        .shape(CheckBoxShape.CIRCLE)
        .width(26)
        .height(26)
        .padding(4)
        .onChange((checked: boolean) => {
          this.toggleComplete(task.id, checked);
        })

      Column() {
        if (this.editingTaskId === task.id) {
          TextInput({ text: this.editingTitle })
            .placeholderColor(this.palette().mutedText)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .caretColor(section.accent)
            .onChange((value: string) => {
              this.editingTitle = value;
            })
        } else {
          Text(task.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(task.completed ? this.palette().mutedText : this.palette().primaryText)
            .decoration({ type: task.completed ? TextDecorationType.LineThrough : TextDecorationType.None })
        }

        Row() {
          if (task.deadline) {
            Text(this.deadlineLabel(task.deadline))
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.deadlineColor(task))
              .padding({ left: 6, right: 6, top: 4, bottom: 4 })
              .backgroundColor(this.deadlineBackground(task))
              .borderRadius(10)
              .margin({ right: 8 })
          }

          Text(`${task.checklist.done}/${task.checklist.total} checklist`)
            .fontSize(12)
            .fontColor(this.palette().secondaryText)
            .padding({ left: 6, right: 6, top: 4, bottom: 4 })
            .backgroundColor(this.palette().subtleCard)
            .borderRadius(10)
        }
        .margin({ top: 6 })
      }
      .layoutWeight(1)
      .margin({ left: 12, right: 12 })

      if (this.editingTaskId === task.id) {
        Row() {
          Text('Save')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(section.accent)
            .onClick(() => this.saveEdit(task.id))
          Text('Cancel')
            .fontSize(14)
            .fontColor(this.palette().secondaryText)
            .margin({ left: 10 })
            .onClick(() => this.cancelEdit())
        }
      } else {
        Row() {
          Text('Edit')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(section.accent)
            .onClick(() => this.startEdit(task))
          Text('Delete')
            .fontSize(14)
            .fontColor(this.palette().secondaryText)
            .margin({ left: 10 })
            .onClick(() => this.deleteTask(task.id))
        }
      }
    }
    .alignItems(VerticalAlign.Center)
    .padding({ top: 12, bottom: 12 })
    .border({ width: 0, color: Color.Transparent })
    .borderRadius(12)
    .backgroundColor(task.completed ? this.palette().subtleCard : Color.Transparent)
  }

  private addQuickTask() {
    const trimmedTitle = this.quickTitle.trim();
    if (!trimmedTitle) {
      return;
    }

    const newTask: Task = {
      id: Date.now(),
      title: trimmedTitle,
      deadline: this.parseDeadline(this.quickDeadline),
      section: this.quickSection,
      completed: false,
      checklist: { done: 0, total: 1 }
    };

    this.tasks = [newTask, ...this.tasks];
    this.quickTitle = '';
    this.quickDeadline = '';
  }

  private toggleComplete(taskId: number, completed: boolean) {
    const updated: Task[] = [];
    this.tasks.forEach((task: Task) => {
      if (task.id === taskId) {
        updated.push({
          id: task.id,
          title: task.title,
          deadline: task.deadline,
          section: task.section,
          completed,
          checklist: task.checklist
        });
      } else {
        updated.push(task);
      }
    });
    this.tasks = updated;
  }

  private startEdit(task: Task) {
    this.editingTaskId = task.id;
    this.editingTitle = task.title;
  }

  private saveEdit(taskId: number) {
    const trimmed = this.editingTitle.trim();
    if (!trimmed) {
      this.deleteTask(taskId);
      return;
    }

    const updated: Task[] = [];
    this.tasks.forEach((task: Task) => {
      if (task.id === taskId) {
        updated.push({
          id: task.id,
          title: trimmed,
          deadline: task.deadline,
          section: task.section,
          completed: task.completed,
          checklist: task.checklist
        });
      } else {
        updated.push(task);
      }
    });
    this.tasks = updated;
    this.cancelEdit();
  }

  private cancelEdit() {
    this.editingTaskId = undefined;
    this.editingTitle = '';
  }

  private deleteTask(taskId: number) {
    this.tasks = this.tasks.filter((task: Task) => task.id !== taskId);
    if (this.editingTaskId === taskId) {
      this.cancelEdit();
    }
  }

  private deadlineLabel(deadline: string): string {
    const date = new Date(deadline);
    const today = new Date();
    const diffMs = date.getTime() - new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime();
    const diffDays = Math.round(diffMs / (1000 * 60 * 60 * 24));

    if (diffDays === 0) {
      return 'Today';
    }
    if (diffDays === 1) {
      return 'Tomorrow';
    }
    if (diffDays === -1) {
      return 'Yesterday';
    }

    return date.toDateString();
  }

  private deadlineColor(task: Task): Color | string {
    if (!task.deadline) {
      return this.palette().secondaryText;
    }
    return this.isOverdue(task.deadline) ? '#D35F5F' : this.palette().primaryText;
  }

  private deadlineBackground(task: Task): Color | string {
    if (!task.deadline) {
      return this.palette().subtleCard;
    }
    return this.isOverdue(task.deadline) ? '#2D0B0B' : this.palette().subtleCard;
  }

  private isOverdue(deadline?: string): boolean {
    if (!deadline) {
      return false;
    }
    const endOfDay = new Date(deadline);
    endOfDay.setHours(23, 59, 59, 999);
    return endOfDay.getTime() < Date.now();
  }

  private parseDeadline(value: string): string | undefined {
    if (!value) {
      return undefined;
    }
    const parsed = new Date(value);
    return isNaN(parsed.getTime()) ? undefined : value;
  }

  private palette(): Palette {
    const isDark = false;
    return {
      background: isDark ? '#0D1117' : '#F5F7FB',
      card: isDark ? '#161B22' : '#FFFFFF',
      subtleCard: isDark ? '#1F252E' : '#F0F4FB',
      primaryText: isDark ? '#E8EDF3' : '#1F2937',
      secondaryText: isDark ? '#C0C7D0' : '#4B5563',
      mutedText: isDark ? '#8D95A1' : '#9CA3AF',
      accent: '#5D9DF6',
      divider: isDark ? '#2C3440' : '#E5E7EB',
      shadow: isDark ? '#66000000' : '#1A1F2B33',
      buttonText: isDark ? '#0D1117' : '#FFFFFF'
    };
  }

  private horizontalPadding(): number {
    return this.layoutIsWide ? 48 : 24;
  }
}
