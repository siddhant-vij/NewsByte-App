const configFilePath = 'config/api.config';

const newsBaseEndpoint = 'https://newsapi.org/v2';
const topHeadlinesEndpoint = '$newsBaseEndpoint/top-headlines';
const everythingEndpoint = '$newsBaseEndpoint/everything';

const summaryEndpoint = 'https://api.openai.com/v1/chat/completions';

const titleLength = 8;
const descriptionLength = 80;

const compressedImageQuality = 80;
const compressedImageMinWidth = 1080;
const compressedImageMinHeight = 720;

const maxSizeOfDeque = 20;
const articlesFetchedAtATime = 5;
const articlesToBeRemoved = 5;
