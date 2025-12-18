import display from '@ohos.display';

enum TaskSection {
  TODAY = 'today',
  UPCOMING = 'upcoming',
  INBOX = 'inbox'
}

class Checklist {
  constructor(public done: number, public total: number) {}
}

class TaskModel {
  constructor(
    public id: number,
    public title: string,
    public section: TaskSection,
    public checklist: Checklist,
    public completed: boolean = false,
    public deadline?: string
  ) {}
}

class SectionMeta {
  constructor(public key: TaskSection, public title: string, public accent: string) {}
}

class Palette {
  constructor(
    public background: string,
    public card: string,
    public subtleCard: string,
    public primaryText: string,
    public secondaryText: string,
    public mutedText: string,
    public accent: string,
    public divider: string,
    public shadow: string,
    public buttonText: string
  ) {}
}

function offsetIsoDate(offsetDays: number): string {
  const date = new Date();
  date.setHours(0, 0, 0, 0);
  date.setDate(date.getDate() + offsetDays);
  return date.toISOString().split('T')[0];
}

@Entry
@Component
struct Index {
  @Environment('colorMode') colorMode: ColorMode = ColorMode.LIGHT;

  @State tasks: TaskModel[] = [
    new TaskModel(1, 'Send the project update to the team', TaskSection.TODAY, new Checklist(1, 3), false, offsetIsoDate(0)),
    new TaskModel(2, 'Refine product roadmap draft', TaskSection.UPCOMING, new Checklist(0, 2), false, offsetIsoDate(2)),
    new TaskModel(3, 'Book venue for offsite', TaskSection.UPCOMING, new Checklist(2, 4), false, offsetIsoDate(7)),
    new TaskModel(4, 'Capture feedback from discovery calls', TaskSection.INBOX, new Checklist(0, 1), false)
  ];

  @State quickTitle: string = '';
  @State quickDeadline: string = '';
  @State quickSection: TaskSection = TaskSection.TODAY;
  @State editingTaskId: number | undefined = undefined;
  @State editingTitle: string = '';
  @State layoutIsWide: boolean = false;

  private sections: SectionMeta[] = [
    new SectionMeta(TaskSection.TODAY, 'Today', '#5D9DF6'),
    new SectionMeta(TaskSection.UPCOMING, 'Upcoming', '#5BC89A'),
    new SectionMeta(TaskSection.INBOX, 'Inbox', '#D0B36A')
  ];

  aboutToAppear(): void {
    display.getDefaultDisplay()
      .then((device) => {
        this.layoutIsWide = device.width >= 720;
      })
      .catch(() => {
        this.layoutIsWide = false;
      });
  }

  build(): void {
    Column() {
      this.RenderHeader();
      this.RenderQuickEntry();

      Column({ space: 14 }) {
        ForEach(this.sections, (section: SectionMeta) => {
          this.RenderSection(section);
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
  RenderHeader(): void {
    Row() {
      Column() {
        Text('Plannist')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.palette().primaryText);
        Text('Capture today, plan ahead, stay calm')
          .fontSize(14)
          .fontColor(this.palette().secondaryText)
          .margin({ top: 4 });
      }
      .alignItems(VerticalAlign.Center);

      Blank().layoutWeight(1);

      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text('+')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.palette().buttonText);
      }
      .width(46)
      .height(46)
      .backgroundColor(this.palette().accent)
      .borderRadius(23)
      .shadow({ radius: 12, color: this.palette().shadow })
      .onClick(() => this.addQuickTask());
    }
    .width('100%')
    .margin({ bottom: 18 });
  }

  @Builder
  RenderQuickEntry(): void {
    Column() {
      Text('Quick Entry')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.palette().primaryText)
        .margin({ bottom: 10 });

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
          .margin({ bottom: 10 });

        Row() {
          Row() {
            ForEach(this.sections, (section: SectionMeta) => {
              Button({ type: ButtonType.Capsule, stateEffect: true }) {
                Text(section.title)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.quickSection === section.key ? this.palette().buttonText : this.palette().primaryText);
              }
              .height(38)
              .margin({ right: 8 })
              .padding({ left: 14, right: 14 })
              .backgroundColor(this.quickSection === section.key ? section.accent : this.palette().card)
              .border({ width: 1, color: this.palette().divider })
              .shadow({ radius: this.quickSection === section.key ? 8 : 0, color: this.palette().shadow })
              .onClick(() => {
                this.quickSection = section.key;
              });
            }, (section: SectionMeta) => section.key);
          }
          .alignItems(VerticalAlign.Center)
          .layoutWeight(1);

          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Text('Add')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.palette().buttonText);
          }
          .height(42)
          .padding({ left: 18, right: 18 })
          .backgroundColor(this.palette().accent)
          .shadow({ radius: 12, color: this.palette().shadow })
          .onClick(() => this.addQuickTask());
        }
        .alignItems(VerticalAlign.Center);

        TextInput({ placeholder: 'Deadline (YYYY-MM-DD, optional)', text: this.quickDeadline })
          .placeholderColor(this.palette().mutedText)
          .fontColor(this.palette().primaryText)
          .caretColor(this.palette().accent)
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .margin({ top: 10 })
          .onChange((value: string) => {
            this.quickDeadline = value;
          });
      }
      .padding(16)
      .backgroundColor(this.palette().card)
      .borderRadius(18)
      .shadow({ radius: 16, color: this.palette().shadow, offsetY: 4 });
    }
    .margin({ bottom: 18 })
    .width('100%');
  }

  @Builder
  RenderSection(section: SectionMeta): void {
    const items: TaskModel[] = this.tasks.filter((task: TaskModel) => task.section === section.key);

    Column() {
      Row() {
        Row() {
          Text(section.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.palette().primaryText);
          Text(`${items.filter((item: TaskModel) => item.completed).length}/${items.length}`)
            .fontSize(14)
            .fontColor(this.palette().mutedText)
            .margin({ left: 8 });
        }

        Blank().layoutWeight(1);

        Text('Add')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(section.accent)
          .onClick(() => {
            this.quickSection = section.key;
            this.addQuickTask();
          });
      }
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 10 });

      if (items.length === 0) {
        this.RenderEmptyState(section);
      } else {
        Column() {
          ForEach(items, (task: TaskModel) => {
            this.RenderTaskRow(task, section);
          }, (task: TaskModel) => task.id.toString());
        };
      }
    }
    .padding(16)
    .backgroundColor(this.palette().card)
    .borderRadius(18)
    .shadow({ radius: 16, color: this.palette().shadow, offsetY: 4 });
  }

  @Builder
  RenderEmptyState(section: SectionMeta): void {
    Column() {
      Text('Nothing here yet')
        .fontSize(14)
        .fontColor(this.palette().secondaryText);
      Text('Tap Add to capture your next step')
        .fontSize(12)
        .fontColor(this.palette().mutedText)
        .margin({ top: 4 });
    }
    .padding({ top: 18, bottom: 18 })
    .width('100%')
    .backgroundColor(this.palette().subtleCard)
    .borderRadius(12)
    .border({ width: 1, color: this.palette().divider });
  }

  @Builder
  RenderTaskRow(task: TaskModel, section: SectionMeta): void {
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
        });

      Column() {
        if (this.editingTaskId === task.id) {
          TextInput({ text: this.editingTitle })
            .placeholderColor(this.palette().mutedText)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .caretColor(section.accent)
            .onChange((value: string) => {
              this.editingTitle = value;
            });
        } else {
          Text(task.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(task.completed ? this.palette().mutedText : this.palette().primaryText)
            .decoration({ type: task.completed ? TextDecorationType.LineThrough : TextDecorationType.None });
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
              .margin({ right: 8 });
          }

          Text(`${task.checklist.done}/${task.checklist.total} checklist`)
            .fontSize(12)
            .fontColor(this.palette().secondaryText)
            .padding({ left: 6, right: 6, top: 4, bottom: 4 })
            .backgroundColor(this.palette().subtleCard)
            .borderRadius(10);
        }
        .margin({ top: 6 });
      }
      .layoutWeight(1)
      .margin({ left: 12, right: 12 });

      if (this.editingTaskId === task.id) {
        Row() {
          Text('Save')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(section.accent)
            .onClick(() => this.saveEdit(task.id));
          Text('Cancel')
            .fontSize(14)
            .fontColor(this.palette().secondaryText)
            .margin({ left: 10 })
            .onClick(() => this.cancelEdit());
        };
      } else {
        Row() {
          Text('Edit')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(section.accent)
            .onClick(() => this.startEdit(task));
          Text('Delete')
            .fontSize(14)
            .fontColor(this.palette().secondaryText)
            .margin({ left: 10 })
            .onClick(() => this.deleteTask(task.id));
        };
      }
    }
    .alignItems(VerticalAlign.Center)
    .padding({ top: 12, bottom: 12 })
    .border({ width: 0, color: Color.Transparent })
    .borderRadius(12)
    .backgroundColor(task.completed ? this.palette().subtleCard : Color.Transparent);
  }

  private addQuickTask(): void {
    const trimmedTitle: string = this.quickTitle.trim();
    if (trimmedTitle.length === 0) {
      return;
    }

    const newTask: TaskModel = new TaskModel(
      Date.now(),
      trimmedTitle,
      this.quickSection,
      new Checklist(0, 1),
      false,
      this.parseDeadline(this.quickDeadline)
    );

    const updated: TaskModel[] = [newTask];
    this.tasks.forEach((task: TaskModel) => updated.push(task));
    this.tasks = updated;

    this.quickTitle = '';
    this.quickDeadline = '';
  }

  private toggleComplete(taskId: number, completed: boolean): void {
    const updated: TaskModel[] = [];
    this.tasks.forEach((task: TaskModel) => {
      if (task.id === taskId) {
        const changed: TaskModel = new TaskModel(task.id, task.title, task.section, task.checklist, completed, task.deadline);
        updated.push(changed);
      } else {
        updated.push(task);
      }
    });
    this.tasks = updated;
  }

  private startEdit(task: TaskModel): void {
    this.editingTaskId = task.id;
    this.editingTitle = task.title;
  }

  private saveEdit(taskId: number): void {
    const trimmed: string = this.editingTitle.trim();
    if (trimmed.length === 0) {
      this.deleteTask(taskId);
      return;
    }

    const updated: TaskModel[] = [];
    this.tasks.forEach((task: TaskModel) => {
      if (task.id === taskId) {
        const changed: TaskModel = new TaskModel(task.id, trimmed, task.section, task.checklist, task.completed, task.deadline);
        updated.push(changed);
      } else {
        updated.push(task);
      }
    });
    this.tasks = updated;
    this.cancelEdit();
  }

  private cancelEdit(): void {
    this.editingTaskId = undefined;
    this.editingTitle = '';
  }

  private deleteTask(taskId: number): void {
    const remaining: TaskModel[] = [];
    this.tasks.forEach((task: TaskModel) => {
      if (task.id !== taskId) {
        remaining.push(task);
      }
    });
    this.tasks = remaining;
    if (this.editingTaskId === taskId) {
      this.cancelEdit();
    }
  }

  private deadlineLabel(deadline: string): string {
    const date: Date = new Date(deadline);
    const today: Date = new Date();
    const diffMs: number = date.getTime() - new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime();
    const diffDays: number = Math.round(diffMs / (1000 * 60 * 60 * 24));

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

  private deadlineColor(task: TaskModel): string | Color {
    if (task.deadline === undefined) {
      return this.palette().secondaryText;
    }
    return this.isOverdue(task.deadline) ? '#D35F5F' : this.palette().primaryText;
  }

  private deadlineBackground(task: TaskModel): string | Color {
    if (task.deadline === undefined) {
      return this.palette().subtleCard;
    }
    return this.isOverdue(task.deadline) ? '#2D0B0B' : this.palette().subtleCard;
  }

  private isOverdue(deadline?: string): boolean {
    if (deadline === undefined) {
      return false;
    }
    const endOfDay: Date = new Date(deadline);
    endOfDay.setHours(23, 59, 59, 999);
    return endOfDay.getTime() < Date.now();
  }

  private parseDeadline(value: string): string | undefined {
    if (value.length === 0) {
      return undefined;
    }
    const parsed: Date = new Date(value);
    return isNaN(parsed.getTime()) ? undefined : value;
  }

  private palette(): Palette {
    const isDark: boolean = this.colorMode === ColorMode.DARK;
    if (isDark) {
      return new Palette('#0D1117', '#161B22', '#1F252E', '#E8EDF3', '#C0C7D0', '#8D95A1', '#5D9DF6', '#2C3440', '#66000000', '#0D1117');
    }
    return new Palette('#F5F7FB', '#FFFFFF', '#F0F4FB', '#1F2937', '#4B5563', '#9CA3AF', '#5D9DF6', '#E5E7EB', '#1A1F2B33', '#FFFFFF');
  }

  private horizontalPadding(): number {
    return this.layoutIsWide ? 48 : 24;
  }
}
